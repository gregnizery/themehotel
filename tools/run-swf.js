const {chromium}=require('playwright-core');const http=require('http');const fs=require('fs');const path=require('path');
const root=path.resolve(__dirname,'..');fs.mkdirSync(path.join(root,'tools','shots'),{recursive:true});
const srv=http.createServer((q,s)=>{const f=path.join(root,decodeURIComponent(q.url.split('?')[0]));
 fs.readFile(f,(e,d)=>{if(e){s.writeHead(404);s.end();return}
 const t=f.endsWith('.wasm')?'application/wasm':f.endsWith('.js')?'text/javascript':f.endsWith('.html')?'text/html':'application/octet-stream';s.writeHead(200,{'Content-Type':t});s.end(d)})}).listen(8123);
(async()=>{const b=await chromium.launch({executablePath:process.env.CHROMIUM_PATH||'/opt/pw-browsers/chromium',args:['--no-sandbox']});
const pg=await b.newPage({viewport:{width:700,height:500},deviceScaleFactor:Number(process.env.SCALE||1)});
pg.on('console',m=>{const t=m.text();if(!/wgpu|WebGL|GPU/.test(t))console.log('C:',t.slice(0,300))});
await pg.goto('http://localhost:8123/tools/player.html?swf=/'+process.argv[2]+'&vars='+encodeURIComponent(process.env.SWF_VARS||''));
const steps=JSON.parse(process.argv[3]||'[]');let i=0;
for(const s of steps){ if(s.wait) await pg.waitForTimeout(s.wait); if(s.click){await pg.mouse.move(s.click[0],s.click[1]);await pg.waitForTimeout(150);await pg.mouse.down();await pg.waitForTimeout(100);await pg.mouse.up();}
 if(s.key) await pg.keyboard.press(s.key); if(s.hold){await pg.keyboard.down(s.hold);await pg.waitForTimeout(s.ms||1000);await pg.keyboard.up(s.hold);} if(s.wheel){await pg.mouse.move(s.wheel[0],s.wheel[1]);await pg.mouse.wheel(0,s.wheel[2]);} if(s.type) await pg.keyboard.type(s.type,{delay:80});
 if(s.shot){await pg.screenshot({path:path.join(root,'tools','shots',s.shot)});console.log('shot',s.shot)} }
await b.close();srv.close();})();
