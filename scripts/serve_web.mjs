import {createServer} from 'node:http';
import {readFile} from 'node:fs/promises';
import path from 'node:path';
import {fileURLToPath} from 'node:url';

const root=path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../flutter_application_1/build/web');
const base='/MicroProyectoSistemas-/';
const mime={'.html':'text/html','.js':'application/javascript','.json':'application/json',
  '.wasm':'application/wasm','.png':'image/png','.ttf':'font/ttf','.otf':'font/otf'};
const server=createServer(async (req,res)=>{
  try {
    const pathname=decodeURIComponent(new URL(req.url,'http://localhost').pathname);
    if(pathname==='/'){res.writeHead(302,{Location:base}).end();return;}
    if(!pathname.startsWith(base)){res.writeHead(404).end();return;}
    const target=path.resolve(root,pathname.slice(base.length)||'index.html');
    if(!target.startsWith(root+path.sep)){res.writeHead(403).end();return;}
    const content=await readFile(target);
    res.writeHead(200,{'Content-Type':mime[path.extname(target)]||'application/octet-stream',
      'Cache-Control':'no-cache'}).end(content);
  }catch {res.writeHead(404).end('Compila primero la versión web y genera su caché.');}
});
const port=Number(process.env.PORT||4173);
server.listen(port,'127.0.0.1',()=>console.log(`15-Puzzle: http://127.0.0.1:${port}${base}`));
