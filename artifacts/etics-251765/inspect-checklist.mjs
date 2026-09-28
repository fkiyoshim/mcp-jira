const base=(process.env.JIRA_BASE_URL||'https://jira.cpqd.com.br').replace(/\/$/,'');
const auth=process.env.JIRA_TOKEN?`Bearer ${process.env.JIRA_TOKEN}`:`Basic ${Buffer.from(process.env.JIRA_USERNAME+':'+process.env.JIRA_PASSWORD).toString('base64')}`;
const r=await fetch(base+'/rest/api/2/issue/ETICS-251765/editmeta',{headers:{Accept:'application/json',Authorization:auth},redirect:'error',signal:AbortSignal.timeout(30000)});
if(!r.ok)throw Error('HTTP '+r.status);
const d=await r.json();
console.log(JSON.stringify(Object.fromEntries(Object.entries(d.fields||{}).filter(([k,v])=>/check|aceit/i.test(v.name))),null,2));
