#!/usr/bin/env node

import readline from "node:readline";
import { extension } from "./write-tools.mjs";

const SERVER_NAME = "cpqd-jira";
const SERVER_VERSION = "1.1.0";
const writeEnabled = process.argv.includes("--write");
const DEFAULT_PROTOCOL_VERSION = "2025-06-18";
const DEFAULT_BASE_URL = "https://jira.cpqd.com.br";
const DEFAULT_PROJECT = "ETICS";

function env(name, fallback = "") {
  const value = process.env[name]?.trim();
  return value || fallback;
}

const baseUrl = env("JIRA_BASE_URL", DEFAULT_BASE_URL).replace(/\/+$/, "");
const defaultProject = env("JIRA_PROJECT_KEY", DEFAULT_PROJECT).toUpperCase();
const allowedProjects = new Set(
  env("JIRA_ALLOWED_PROJECTS", defaultProject)
    .split(",")
    .map((value) => value.trim().toUpperCase())
    .filter(Boolean),
);
const requestTimeoutMs = Number(env("JIRA_TIMEOUT_MS", "30000"));

function authHeader() {
  const token = env("JIRA_TOKEN");
  if (token) return `Bearer ${token}`;

  const username = env("JIRA_USERNAME");
  const password = env("JIRA_PASSWORD");
  if (username && password) {
    return `Basic ${Buffer.from(`${username}:${password}`, "utf8").toString("base64")}`;
  }

  throw new Error(
    "Credenciais ausentes. Defina JIRA_TOKEN ou JIRA_USERNAME e JIRA_PASSWORD.",
  );
}

function projectKey(input) {
  const key = String(input || defaultProject).trim().toUpperCase();
  if (!/^[A-Z][A-Z0-9_]*$/.test(key)) throw new Error("project_key invalido.");
  if (!allowedProjects.has(key)) {
    throw new Error(
      `Projeto ${key} nao permitido. Projetos autorizados: ${[...allowedProjects].join(", ")}.`,
    );
  }
  return key;
}

function issueKey(input) {
  const key = String(input || "").trim().toUpperCase();
  const match = /^([A-Z][A-Z0-9_]*)-([1-9][0-9]*)$/.exec(key);
  if (!match) throw new Error("issue_key invalido.");
  projectKey(match[1]);
  return key;
}

function positiveInteger(value, fallback, maximum = Number.MAX_SAFE_INTEGER) {
  if (value === undefined || value === null || value === "") return fallback;
  const parsed = Number(value);
  if (!Number.isInteger(parsed) || parsed < 0 || parsed > maximum) {
    throw new Error(`Valor numerico invalido: ${value}.`);
  }
  return parsed;
}

function assertBalancedJql(value) {
  let depth = 0;
  let quote = "";
  for (let index = 0; index < value.length; index += 1) {
    const character = value[index];
    if (quote) {
      if (character === "\\") index += 1;
      else if (character === quote) quote = "";
      continue;
    }
    if (character === "\"" || character === "'") quote = character;
    else if (character === "(") depth += 1;
    else if (character === ")") depth -= 1;
    if (depth < 0) throw new Error("jql invalido: parenteses desbalanceados.");
  }
  if (depth !== 0 || quote) throw new Error("jql invalido: expressao incompleta.");
}

function scopedJql(input) {
  const raw = String(input || "").trim();
  if (!raw) throw new Error("jql nao pode ficar vazio.");
  if (raw.length > 2000) throw new Error("jql excede 2000 caracteres.");

  const orderMatch = /\s+ORDER\s+BY\s+([A-Za-z0-9_.,\s-]+)$/i.exec(raw);
  const filter = orderMatch ? raw.slice(0, orderMatch.index).trim() : raw;
  if (!filter) throw new Error("jql nao pode conter apenas ORDER BY.");
  assertBalancedJql(filter);

  const projects = [...allowedProjects].map((key) => `\"${key}\"`).join(", ");
  const orderBy = orderMatch ? ` ORDER BY ${orderMatch[1].trim()}` : "";
  return `project in (${projects}) AND (${filter})${orderBy}`;
}

async function jiraRequest(pathname, query = {}, options = {}) {
  const method = options.method || "GET";
  if (method !== "GET" && !writeEnabled) throw new Error("Escrita desabilitada. Inicie com --write.");
  const url = new URL(`${baseUrl}${pathname}`);
  for (const [key, value] of Object.entries(query)) {
    if (value !== undefined && value !== null && value !== "") {
      url.searchParams.set(key, String(value));
    }
  }

  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), requestTimeoutMs);
  try {
    const response = await fetch(url, {
      method,
      redirect: "error",
      headers: {
        Accept: "application/json",
        Authorization: authHeader(),
        "User-Agent": `${SERVER_NAME}/${SERVER_VERSION}`,
        ...(options.body === undefined ? {} : { "Content-Type": "application/json" }),
      },
      signal: controller.signal,
      ...(options.body === undefined ? {} : { body: JSON.stringify(options.body) }),
    });

    const body = await response.text();
    let data;
    try {
      data = body ? JSON.parse(body) : null;
    } catch {
      data = body;
    }

    if (!response.ok) {
      const detail =
        data?.errorMessages?.filter(Boolean).join("; ") ||
        (data?.errors && Object.values(data.errors).filter(Boolean).join("; ")) ||
        data?.message ||
        String(data || response.statusText);
      throw new Error(`Jira respondeu HTTP ${response.status}: ${detail}`);
    }
    return data ?? { success: true, httpStatus: response.status };
  } catch (error) {
    if (error?.name === "AbortError") {
      throw new Error(`Tempo limite excedido ao acessar ${url.origin}.`);
    }
    throw error;
  } finally {
    clearTimeout(timeout);
  }
}

const pagingProperties = {
  max_results: { type: "integer", minimum: 1, maximum: 100, default: 25 },
  start_at: { type: "integer", minimum: 0, default: 0 },
};

const tools = [
  {
    name: "jira_get_issue",
    description: "Obtem os detalhes de uma issue Jira autorizada.",
    inputSchema: {
      type: "object",
      properties: {
        issue_key: { type: "string", description: "Chave da issue, por exemplo ETICS-239275." },
        fields: {
          type: "array",
          items: { type: "string" },
          description: "Campos opcionais a retornar. Por padrao retorna os campos principais.",
        },
      },
      required: ["issue_key"],
      additionalProperties: false,
    },
  },
  {
    name: "jira_search_issues",
    description: "Pesquisa issues com JQL, sempre limitada aos projetos autorizados.",
    inputSchema: {
      type: "object",
      properties: {
        jql: { type: "string", description: "Filtro JQL. Pode incluir ORDER BY ao final." },
        fields: { type: "array", items: { type: "string" } },
        ...pagingProperties,
      },
      required: ["jql"],
      additionalProperties: false,
    },
  },
  {
    name: "jira_get_comments",
    description: "Lista comentarios de uma issue Jira autorizada.",
    inputSchema: {
      type: "object",
      properties: {
        issue_key: { type: "string" },
        ...pagingProperties,
      },
      required: ["issue_key"],
      additionalProperties: false,
    },
  },
  {
    name: "jira_get_project",
    description: "Obtem detalhes de um projeto Jira autorizado.",
    inputSchema: {
      type: "object",
      properties: {
        project_key: {
          type: "string",
          description: `Chave do projeto. Padrao: ${defaultProject}.`,
        },
      },
      additionalProperties: false,
    },
  },
].map((tool) => ({
  ...tool,
  annotations: { readOnlyHint: true, destructiveHint: false, idempotentHint: true },
}));
const extra = extension({ request: jiraRequest, projectKey, issueKey, writeEnabled });
tools.push(...extra.tools);

const defaultFields = [
  "summary",
  "status",
  "assignee",
  "reporter",
  "priority",
  "issuetype",
  "created",
  "updated",
  "description",
  "labels",
  "components",
  "fixVersions",
];

function fields(input) {
  const selected = input === undefined ? defaultFields : input;
  if (!Array.isArray(selected) || selected.length === 0) {
    throw new Error("fields deve ser uma lista nao vazia.");
  }
  const normalized = selected.map((field) => String(field).trim());
  if (normalized.some((field) => !/^[A-Za-z0-9_.-]+$/.test(field))) {
    throw new Error("fields contem um nome invalido.");
  }
  return normalized.join(",");
}

async function callTool(name, args = {}) {
  switch (name) {
    case "jira_get_issue": {
      const key = encodeURIComponent(issueKey(args.issue_key));
      return jiraRequest(`/rest/api/2/issue/${key}`, { fields: fields(args.fields) });
    }
    case "jira_search_issues":
      return jiraRequest("/rest/api/2/search", {
        jql: scopedJql(args.jql),
        fields: fields(args.fields),
        startAt: positiveInteger(args.start_at, 0),
        maxResults: positiveInteger(args.max_results, 25, 100),
      });
    case "jira_get_comments": {
      const key = encodeURIComponent(issueKey(args.issue_key));
      return jiraRequest(`/rest/api/2/issue/${key}/comment`, {
        startAt: positiveInteger(args.start_at, 0),
        maxResults: positiveInteger(args.max_results, 25, 100),
      });
    }
    case "jira_get_project": {
      const key = encodeURIComponent(projectKey(args.project_key));
      return jiraRequest(`/rest/api/2/project/${key}`);
    }
    default:
      return extra.call(name, args);
  }
}

function send(message) {
  process.stdout.write(`${JSON.stringify(message)}\n`);
}

function result(id, value) {
  send({ jsonrpc: "2.0", id, result: value });
}

function rpcError(id, code, message) {
  send({ jsonrpc: "2.0", id, error: { code, message } });
}

async function handle(message) {
  if (!message || message.jsonrpc !== "2.0" || !message.method) return;
  const { id, method, params = {} } = message;

  try {
    if (method === "initialize") {
      result(id, {
        protocolVersion: params.protocolVersion || DEFAULT_PROTOCOL_VERSION,
        capabilities: { tools: { listChanged: false } },
        serverInfo: { name: SERVER_NAME, version: SERVER_VERSION },
        instructions:
          `Integracao Jira e Zephyr Scale ${writeEnabled ? "com criacao e edicao habilitadas" : "somente leitura"}. Use o projeto ${defaultProject} por padrao. ` +
          "Antes de criar, consulte itens existentes para evitar duplicacao. Nao repita uma escrita apos timeout sem verificar o resultado. " +
          "Nunca solicite, exiba ou grave tokens; as credenciais sao fornecidas pelo ambiente.",
      });
      return;
    }
    if (method === "ping") {
      result(id, {});
      return;
    }
    if (method === "tools/list") {
      result(id, { tools });
      return;
    }
    if (method === "tools/call") {
      try {
        const data = await callTool(params.name, params.arguments || {});
        result(id, {
          content: [{ type: "text", text: JSON.stringify(data, null, 2) }],
          structuredContent: { data },
          isError: false,
        });
      } catch (error) {
        result(id, {
          content: [{ type: "text", text: error?.message || String(error) }],
          isError: true,
        });
      }
      return;
    }
    if (id !== undefined) rpcError(id, -32601, `Metodo nao encontrado: ${method}.`);
  } catch (error) {
    if (id !== undefined) rpcError(id, -32603, error?.message || String(error));
  }
}

const input = readline.createInterface({ input: process.stdin, crlfDelay: Infinity });
input.on("line", (line) => {
  if (!line.trim()) return;
  try {
    void handle(JSON.parse(line));
  } catch (error) {
    rpcError(null, -32700, `JSON invalido: ${error.message}`);
  }
});

process.on("uncaughtException", (error) => {
  process.stderr.write(`[${SERVER_NAME}] ${error.stack || error.message}\n`);
});
