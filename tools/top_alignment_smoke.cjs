const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const assert = require('node:assert/strict');
const fs = require('node:fs/promises');

(async () => {
  const browser = await chromium.launch({ channel: 'msedge', headless: true });
  const page = await browser.newPage({ viewport: { width: 553, height: 912 } });
  page.setDefaultTimeout(20000);
  const errors = [];
  page.on('pageerror', error => errors.push(error.message));
  const click = async name => {
    await page.getByRole('button', { name }).first().click();
    await page.waitForTimeout(450);
  };
  const headerPositions = [];
  const checkBack = async name => {
    const back = page.getByRole('button', { name: /^Retour/ }).first();
    const box = await back.boundingBox();
    assert.ok(box && box.y >= 0 && box.y <= 24, name + ': unexpected back button position ' + JSON.stringify(box));
    headerPositions.push({ screen: name, y: box.y });
    await page.screenshot({ path: 'output/qa/top-alignment-' + name + '.png' });
  };
  try {
    await fs.mkdir('output/qa', { recursive: true });
    await page.goto(process.argv[2] || 'http://127.0.0.1:8091');
    const semantics = page.locator('flt-semantics-placeholder');
    await semantics.waitFor({ state: 'attached', timeout: 30000 });
    await semantics.evaluate(node => node.click());
    await click(/Passer/);
    await page.getByRole('textbox').first().fill('77 123 45 67');
    await click(/^Continuer$/);
    await checkBack('otp');
    for (const digit of ['1', '2', '3', '4']) {
      await page.getByRole('button', { name: new RegExp('^Chiffre ' + digit) }).click();
    }
    await click(/^Agriculteur/);
    await click(/^Continuer$/);
    await click(/^Entrer dans mon espace$/);
    await click(/^Récoltes$/);
    await page.getByRole('button', { name: /^Modifier$/ }).nth(1).click();
    await page.waitForTimeout(500);
    for (const size of [
      { width: 553, height: 912 },
      { width: 320, height: 844 },
      { width: 1440, height: 1000 },
    ]) {
      await page.setViewportSize(size);
      await page.mouse.move(2, 2);
      await page.waitForTimeout(500);
      await checkBack('harvest-edit-' + size.width);
    }
    await click(/^Retour/);
    await click(/^Profil$/);
    await click(/^Paramètres/);
    await checkBack('settings-desktop');
    assert.deepEqual(errors, []);
    console.log(JSON.stringify({ success: true, headerPositions, errors }));
  } catch (error) {
    await page.screenshot({ path: 'output/qa/top-alignment-failure.png' });
    console.error(await page.locator('body').ariaSnapshot());
    throw error;
  } finally {
    await browser.close();
  }
})().catch(error => { console.error(error); process.exitCode = 1; });
