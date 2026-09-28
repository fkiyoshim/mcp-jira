const fs = require('fs');
const b = fs.readFileSync(process.argv[2]);
const size = 1 << b.readUInt16LE(30), miniSize = 1 << b.readUInt16LE(32);
const sector = id => b.subarray((id + 1) * size, (id + 2) * size);
let fatIds = [];
for (let p=76;p<512;p+=4) { const id=b.readInt32LE(p); if(id>=0) fatIds.push(id); }
let dif=b.readInt32LE(68);
while(dif>=0) {const s=sector(dif); for(let p=0;p<size-4;p+=4) {const id=s.readInt32LE(p);if(id>=0)fatIds.push(id);}dif=s.readInt32LE(size-4);}
const fat=Buffer.concat(fatIds.map(sector));
function chain(id, table=fat, get=sector) {const parts=[],seen=new Set();while(id>=0){if(seen.has(id))throw Error('cycle');seen.add(id);parts.push(get(id));id=table.readInt32LE(id*4);}return Buffer.concat(parts);}
const dir=chain(b.readInt32LE(48)), entries=[];
for(let p=0;p<dir.length;p+=128){const n=dir.readUInt16LE(p+64);if(n>0)entries.push({name:dir.subarray(p,p+n-2).toString('utf16le'),type:dir[p+66],start:dir.readInt32LE(p+116),size:Number(dir.readBigUInt64LE(p+120))});}
const root=entries.find(x=>x.type===5), mini=chain(root.start).subarray(0,root.size), miniFat=chain(b.readInt32LE(60));
function stream(name){const e=entries.find(x=>x.name===name);if(!e)throw Error('Missing '+name);return (e.size<b.readUInt32LE(56)?chain(e.start,miniFat,id=>mini.subarray(id*miniSize,(id+1)*miniSize)):chain(e.start)).subarray(0,e.size);}
const word=stream('WordDocument'), table=stream((word.readUInt16LE(10)&0x200)?'1Table':'0Table');
const fc=word.readUInt32LE(0x1a2), len=word.readUInt32LE(0x1a6), clx=table.subarray(fc,fc+len);
let p=0;while(clx[p]===1)p+=3+clx.readUInt16LE(p+1);if(clx[p]!==2)throw Error('No piece table');
const plc=clx.subarray(p+5,p+5+clx.readUInt32LE(p+1)), n=(plc.length-4)/12;
let out=''; const decoder=new TextDecoder('windows-1252');
for(let i=0;i<n;i++){const count=plc.readUInt32LE((i+1)*4)-plc.readUInt32LE(i*4), encoded=plc.readUInt32LE((n+1)*4+i*8+2), compressed=!!(encoded&0x40000000),offset=(encoded&0x3fffffff)/(compressed?2:1);const bytes=word.subarray(offset,offset+count*(compressed?1:2));out+=compressed?decoder.decode(bytes):bytes.toString('utf16le');}
fs.writeFileSync(process.argv[3],out.replace(/\r/g,'\n').replace(/\x07/g,' | '));
console.log(JSON.stringify({characters:out.length,pieces:n,streams:entries.map(x=>x.name)}));
