import { chromium } from 'playwright';
import { createServer } from 'node:http';
import { readFile, mkdir } from 'node:fs/promises';
import path from 'node:path';
import { fileURLToPath } from 'node:url';
import assert from 'node:assert/strict';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '../flutter_application_1/build/web');
const base = '/MicroProyectoSistemas-/';
const mime = {'.html':'text/html', '.js':'application/javascript', '.json':'application/json', '.wasm':'application/wasm',
  '.png':'image/png', '.ttf':'font/ttf', '.otf':'font/otf', '.bin':'application/octet-stream'};
const server = createServer(async (req,res) => {
  try {
    const pathname = decodeURIComponent(new URL(req.url, 'http://localhost').pathname);
    if (!pathname.startsWith(base)) { res.writeHead(404).end(); return; }
    const target = path.resolve(root, pathname.slice(base.length) || 'index.html');
    if (!target.startsWith(root + path.sep) && target !== root) { res.writeHead(403).end(); return; }
    const content = await readFile(target);
    res.writeHead(200, {'Content-Type':mime[path.extname(target)] || 'application/octet-stream',
      'Cache-Control':'no-cache'}).end(content);
  } catch { res.writeHead(404).end(); }
});
await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
const origin = `http://127.0.0.1:${server.address().port}`;
const output = path.resolve('test-results');
await mkdir(output, {recursive:true});
let browser;
let page;
try {
  browser = await chromium.launch({headless:true});
  const context = await browser.newContext({viewport:{width:1280,height:900}, serviceWorkers:'allow'});
  page = await context.newPage();
  const failures = [];
  const outside = [];
  page.on('pageerror', error => failures.push(error.message));
  page.on('request', request => {
    if (/^https?:/.test(request.url()) && !request.url().startsWith(origin)) outside.push(request.url());
  });
  // El juego debe poder cargar sin descargar CanvasKit ni fuentes desde un CDN.
  await context.route('**/*', route => {
    const url=route.request().url();
    return /^https?:/.test(url) && !url.startsWith(origin) ? route.abort() : route.continue();
  });
  async function accessibility() {
    await page.waitForFunction(() => document.querySelector('flt-semantics-placeholder') || document.querySelector('flt-semantics'), null, {timeout:60000});
    const placeholder = page.locator('flt-semantics-placeholder');
    if (await placeholder.count()) await placeholder.evaluate(node => node.click());
  }
  async function menu() {
    await accessibility();
    await page.getByRole('button', {name:'Jugar', exact:true}).waitFor({timeout:60000});
    await page.waitForTimeout(500);
  }
  await page.goto(origin + base);
  await menu();
  await page.evaluate(async () => {
    await navigator.serviceWorker.ready;
    if (!navigator.serviceWorker.controller) await new Promise(resolve => navigator.serviceWorker.addEventListener('controllerchange',resolve,{once:true}));
  });
  await page.screenshot({path:path.join(output,'menu-desktop.png')});
  await page.getByRole('button',{name:/^Configuración/}).click();
  await page.getByText('Tu juego, a tu manera.',{exact:false}).waitFor();
  await page.getByRole('switch').click();
  await page.waitForFunction(() => JSON.parse(JSON.parse(localStorage.getItem('flutter.puzzle.configuracion') || '"{}"')).animaciones === false);
  await page.screenshot({path:path.join(output,'configuracion-desktop.png')});
  await page.setViewportSize({width:390,height:844});
  await page.screenshot({path:path.join(output,'configuracion-mobile.png')});
  await page.setViewportSize({width:1280,height:900});
  await page.getByRole('button',{name:/Back|Atrás/}).click();
  await page.getByRole('button',{name:/^Cómo jugar/}).click();
  await page.getByText('Encuentra el orden.',{exact:false}).waitFor();
  await page.screenshot({path:path.join(output,'instrucciones-desktop.png')});
  await page.getByRole('button',{name:/Back|Atrás/}).click();
  await page.getByRole('button',{name:/^Marcadores/}).click();
  await page.getByText('Tu primera victoria te espera.',{exact:false}).waitFor();
  await page.screenshot({path:path.join(output,'marcadores-vacios.png')});
  await page.getByRole('button',{name:/Back|Atrás/}).click();
  const manifest = await (await page.request.get(origin + base + 'manifest.json')).json();
  assert.equal(manifest.display,'standalone');
  assert.equal(manifest.start_url,'./');
  assert(manifest.icons.some(icon => icon.sizes==='192x192'));
  assert(manifest.icons.some(icon => icon.sizes==='512x512'));
  const cdp = await context.newCDPSession(page);
  const installability = await cdp.send('Page.getInstallabilityErrors');
  assert.deepEqual(installability.installabilityErrors, [], 'La PWA debe ser instalable en Chromium');
  // Una victoria real desde un tablero de un movimiento se verifica en Flutter.
  // Aquí se comprueba persistencia del plugin web y una recarga totalmente offline.
  await page.evaluate(() => localStorage.setItem('flutter.puzzle.configuracion', JSON.stringify(JSON.stringify({
    dificultad:3,tema:'dark',estilo:'colorido',animaciones:false
  }))));
  await page.reload(); await menu();
  await page.getByRole('button',{name:'Jugar',exact:true}).click();
  await page.getByText('Fácil · 3 × 3',{exact:false}).waitFor();
  await page.screenshot({path:path.join(output,'tablero-desktop.png')});
  await cdp.send('Network.enable');
  await cdp.send('Network.setCacheDisabled',{cacheDisabled:true});
  await context.setOffline(true);
  await cdp.send('Network.overrideNetworkState', {offline:true, latency:0, downloadThroughput:-1, uploadThroughput:-1});
  // Apagar el servidor impide que incluso un worker obtenga recursos de la red.
  await new Promise(resolve => server.close(resolve));
  await page.reload(); await menu();
  await page.getByRole('button',{name:'Jugar',exact:true}).click();
  await page.getByText('Fácil · 3 × 3',{exact:false}).waitFor();
  await page.screenshot({path:path.join(output,'tablero-offline.png')});
  assert.equal(await page.evaluate(() => navigator.onLine),false);
  const networkBlocked = await page.evaluate(async url => {
    try { await fetch(url,{cache:'no-store'}); return false; } catch { return true; }
  }, origin + '/__offline_probe');
  assert.equal(networkBlocked, true, 'La red debe estar realmente desconectada');
  await page.setViewportSize({width:390,height:844});
  await page.screenshot({path:path.join(output,'tablero-mobile.png')});
  assert.deepEqual(failures, [], 'Errores JavaScript');
  assert.deepEqual(outside, [], 'Recursos externos inesperados');
  console.log('PWA OK: instalable en Chromium, worker, recursos locales, persistencia y recarga offline con servidor apagado.');
  await context.close();
} catch (error) {
  if (page && !page.isClosed()) await page.screenshot({path:path.join(output,'fallo.png')}).catch(() => {});
  if(page && !page.isClosed()) console.error(await page.locator('body').ariaSnapshot().catch(()=>''));
  throw error;
} finally {
  await browser?.close();
  if(server.listening) await new Promise(resolve => server.close(resolve));
}
