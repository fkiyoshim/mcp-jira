import assert from "node:assert/strict";
import { spawn } from "node:child_process";
import http from "node:http";
import readline from "node:readline";
import test from "node:test";
import { fileURLToPath } from "node:url";

const serverPath = fileURLToPath(new URL("./server.mjs", import.meta.url));

function startMockJira() {
  const requests = [];
  const server = http.createServer(async (request, response) => {
    let raw = '';
    for await (const chunk of request) raw += chunk;
    requests.push({ url: request.url, authorization: request.headers.authorization, method:request.method, body:raw ? JSON.parse(raw) : null });
    response.setHeader("Content-Type", "application/json");

    if (request.method === 'POST') {
      response.statusCode = 201;
      response.end(JSON.stringify({key:'ETICS-T2'}));
      return;
    }
    if (request.method === 'PUT') {
      response.statusCode = 204;
      response.end();
      return;
    }

    if (request.url.startsWith("/rest/api/2/issue/ETICS-239275/comment")) {
      response.end(JSON.stringify({ comments: [{ id: "1", body: "comentario" }], total: 1 }));
      return;
    }
    if (request.url.startsWith("/rest/api/2/issue/ETICS-239275")) {
      response.end(JSON.stringify({ key: "ETICS-239275", fields: { summary: "Issue de teste" } }));
      return;
    }
    if (request.url.startsWith("/rest/api/2/search")) {
      response.end(JSON.stringify({ issues: [{ key: "ETICS-239275" }], total: 1 }));
      return;
    }
    response.end(JSON.stringify({ key: "ETICS", name: "ETICS" }));
  });

  return new Promise((resolve) => {
    server.listen(0, "127.0.0.1", () => {
      resolve({ server, requests, port: server.address().port });
    });
  });
}

function rpcClient(child) {
  let nextId = 1;
  const pending = new Map();
  const lines = readline.createInterface({ input: child.stdout });
  lines.on("line", (line) => {
    const message = JSON.parse(line);
    pending.get(message.id)?.(message);
    pending.delete(message.id);
  });

  return (method, params = {}) =>
    new Promise((resolve, reject) => {
      const id = nextId++;
      const timer = setTimeout(() => reject(new Error(`Timeout em ${method}`)), 3000);
      pending.set(id, (message) => {
        clearTimeout(timer);
        resolve(message);
      });
      child.stdin.write(`${JSON.stringify({ jsonrpc: "2.0", id, method, params })}\n`);
    });
}

test("inicializa, lista ferramentas e consulta uma issue", async (t) => {
  const mock = await startMockJira();
  t.after(() => mock.server.close());

  const child = spawn(process.execPath, [serverPath], {
    env: {
      ...process.env,
      JIRA_BASE_URL: `http://127.0.0.1:${mock.port}`,
      JIRA_TOKEN: "token-de-teste",
    },
    stdio: ["pipe", "pipe", "pipe"],
  });
  t.after(() => child.kill());
  const rpc = rpcClient(child);

  const initialized = await rpc("initialize", { protocolVersion: "2025-06-18" });
  assert.equal(initialized.result.serverInfo.name, "cpqd-jira");

  const listed = await rpc("tools/list");
  assert.deepEqual(
    listed.result.tools.slice(0, 4).map((tool) => tool.name),
    ["jira_get_issue", "jira_search_issues", "jira_get_comments", "jira_get_project"],
  );
  assert.ok(listed.result.tools.every(tool => tool.annotations.readOnlyHint));

  const issue = await rpc("tools/call", {
    name: "jira_get_issue",
    arguments: { issue_key: "ETICS-239275" },
  });
  assert.equal(issue.result.structuredContent.data.key, "ETICS-239275");
  assert.equal(mock.requests[0].authorization, "Bearer token-de-teste");
  assert.match(mock.requests[0].url, /^\/rest\/api\/2\/issue\/ETICS-239275\?fields=/);
});

test('modo --write publica ferramentas e envia JSON autenticado por POST/PUT',async(t)=>{
  const mock=await startMockJira(); t.after(()=>mock.server.close());
  const child=spawn(process.execPath,[serverPath,'--write'],{env:{...process.env,JIRA_BASE_URL:`http://127.0.0.1:${mock.port}`,JIRA_TOKEN:'token-de-teste'},stdio:['pipe','pipe','pipe']});
  t.after(()=>child.kill()); const rpc=rpcClient(child);
  const listed=await rpc('tools/list');
  assert.ok(listed.result.tools.some(t=>t.name==='zephyr_create_cycle' && !t.annotations.readOnlyHint));
  const created=await rpc('tools/call',{name:'zephyr_create_test',arguments:{name:'Caso',steps:[{description:'Acao',expectedResult:'Resultado'}]}});
  assert.equal(created.result.structuredContent.data.key,'ETICS-T2');
  assert.equal(mock.requests[0].method,'POST');
  assert.equal(mock.requests[0].authorization,'Bearer token-de-teste');
  assert.equal(mock.requests[0].body.testScript.type,'STEP_BY_STEP');
  const updated=await rpc('tools/call',{name:'zephyr_update_test',arguments:{key:'ETICS-T2',name:'Novo nome'}});
  assert.deepEqual(updated.result.structuredContent.data,{success:true,httpStatus:204});
  assert.equal(mock.requests.at(-1).method,'PUT');
});

test("limita a busca JQL ao projeto autorizado", async (t) => {
  const mock = await startMockJira();
  t.after(() => mock.server.close());

  const child = spawn(process.execPath, [serverPath], {
    env: {
      ...process.env,
      JIRA_BASE_URL: `http://127.0.0.1:${mock.port}`,
      JIRA_TOKEN: "token-de-teste",
    },
    stdio: ["pipe", "pipe", "pipe"],
  });
  t.after(() => child.kill());
  const rpc = rpcClient(child);

  const search = await rpc("tools/call", {
    name: "jira_search_issues",
    arguments: { jql: "status = Open ORDER BY updated DESC", max_results: 10 },
  });
  assert.equal(search.result.structuredContent.data.total, 1);
  const requestUrl = new URL(mock.requests[0].url, "http://localhost");
  assert.equal(
    requestUrl.searchParams.get("jql"),
    'project in ("ETICS") AND (status = Open) ORDER BY updated DESC',
  );
  assert.equal(requestUrl.searchParams.get("maxResults"), "10");
});

test("bloqueia issues fora da allowlist antes de chamar a API", async (t) => {
  const mock = await startMockJira();
  t.after(() => mock.server.close());

  const child = spawn(process.execPath, [serverPath], {
    env: {
      ...process.env,
      JIRA_BASE_URL: `http://127.0.0.1:${mock.port}`,
      JIRA_TOKEN: "token-de-teste",
    },
    stdio: ["pipe", "pipe", "pipe"],
  });
  t.after(() => child.kill());
  const rpc = rpcClient(child);

  const response = await rpc("tools/call", {
    name: "jira_get_issue",
    arguments: { issue_key: "OUTRO-1" },
  });
  assert.equal(response.result.isError, true);
  assert.match(response.result.content[0].text, /nao permitido/);
  assert.equal(mock.requests.length, 0);
});
