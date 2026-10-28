// Verificação adicional da versão Web compilada. Requer Playwright e Chrome.
const { chromium } = require('playwright');
const path = require('node:path');
const assert = require('node:assert/strict');

(async () => {
  const browser = await chromium.launch({
    executablePath: process.env.CHROME_PATH || 'C:/Program Files/Google/Chrome/Application/chrome.exe',
    headless: true,
  });
  try {
    const context = await browser.newContext({viewport: {width: 390, height: 860}, deviceScaleFactor: 2, locale: 'pt-BR'});
    const page = await context.newPage();
    const errors = [];
    page.on('pageerror', e => errors.push(String(e)));
    const shots = path.resolve(__dirname, '../docs/capturas');
    await page.goto(process.env.APP_URL || 'http://127.0.0.1:8742');
    await page.locator('flt-semantics-placeholder').evaluate(e => e.click());
    await page.getByRole('button', {name:'Pesquisar locais', exact:true}).waitFor();
    await page.waitForTimeout(1200);
    await page.screenshot({path: path.join(shots, '01-mapa.png')});
    await page.getByRole('textbox').fill('Academia');
    await page.getByRole('button', {name:'Pesquisar locais', exact:true}).click();
    await page.getByRole('button', {name:/Academia Fitness/}).waitFor();
    await page.waitForTimeout(1200);
    await page.screenshot({path: path.join(shots, '02-resultados.png')});
    await page.getByRole('button', {name:/Academia Fitness/}).click();
    await page.getByText('Sobre', {exact:true}).waitFor();
    await page.waitForTimeout(1200);
    await page.screenshot({path: path.join(shots, '03-detalhes.png')});
    await page.getByRole('button', {name:'Adicionar aos favoritos', exact:true}).click();
    await page.waitForTimeout(900);
    const saved = await page.evaluate(() => Object.fromEntries(Object.entries(localStorage)));
    const key = Object.keys(saved).find(k=>k.endsWith('perto.locais.v1'));
    assert.ok(key, 'Dados locais gravados no armazenamento real do navegador');
    // O plugin Web serializa o valor String; dentro dele está o JSON do catálogo.
    const value = JSON.parse(saved[key]);
    const records = typeof value === 'string' ? JSON.parse(value) : value;
    assert.equal(records.find(l=>l.id === 'demo-0-0').favorito, true);
    await page.reload();
    await page.locator('flt-semantics-placeholder').evaluate(e => e.click());
    await page.getByRole('button', {name:'Pesquisar locais', exact:true}).waitFor();
    await page.getByRole('button', {name:'Favoritos', exact:true}).click();
    await page.getByRole('button', {name:/Academia Fitness/}).waitFor();
    assert.equal(await page.getByRole('button', {name:/Academia Fitness/}).count(), 1);
    assert.deepEqual(errors, []);
    console.log('PASS: três telas renderizadas, favorito persistido e recuperado após reload, sem pageerrors.');
  } finally { await browser.close(); }
})().catch(e => {console.error(e); process.exitCode = 1;});
