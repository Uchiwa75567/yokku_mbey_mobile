const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const assert = require('node:assert/strict');
const fs = require('node:fs/promises');

(async () => {
  const browser = await chromium.launch({ channel: 'msedge', headless: true });
  const page = await browser.newPage({ viewport: { width: 390, height: 844 } });
  page.setDefaultTimeout(25000);
  const errors = [];
  const restored = [];
  page.on('pageerror', error => errors.push(error.message));
  const button = name => page.getByRole('button', { name, exact: true }).first();
  const click = async name => {
    await button(name).click();
    await page.waitForTimeout(450);
  };
  const semantics = async () => {
    const placeholder = page.locator('flt-semantics-placeholder');
    await placeholder.waitFor({ state: 'attached', timeout: 30000 });
    await placeholder.evaluate(node => node.click());
  };
  const workspace = () => page.evaluate(() => {
    const entry = Object.entries(localStorage).find(([key]) => key.includes('yokku_mbey.demo.workspace'));
    if (!entry) return null;
    let data = JSON.parse(entry[1]);
    if (typeof data === 'string') data = JSON.parse(data);
    return data;
  });
  const login = async (phone = '77 123 45 67') => {
    const field = page.getByRole('textbox').first();
    await field.waitFor();
    await page.waitForTimeout(500);
    await field.fill(phone);
    await click('Continuer');
    for (const digit of ['1', '2', '3', '4']) {
      await button(new RegExp('^Chiffre ' + digit)).click();
    }
    await page.waitForTimeout(600);
  };
  const logout = async () => {
    await click('Profil');
    await click('Se d\u00e9connecter');
    await click('Se d\u00e9connecter');
  };
  const choose = async name => {
    await click(new RegExp('^' + name));
    await click('Continuer');
  };
  try {
    await fs.mkdir('output/qa', { recursive: true });
    await page.goto(process.argv[2] || 'http://127.0.0.1:8091');
    await semantics();
    await click(/Passer/);
    await login();
    await button(/^Acheteur/).waitFor();
    assert.ok(await button('Continuer').isDisabled());
    await choose('Acheteur');
    assert.equal(await workspace(), null);
    for (const size of [
      { width: 320, height: 844 },
      { width: 390, height: 844 },
      { width: 1440, height: 1000 },
    ]) {
      await page.setViewportSize(size);
      await page.waitForTimeout(450);
      const rect = await button('Entrer dans mon espace').boundingBox();
      assert.ok(rect && rect.y >= 0 && rect.y + rect.height <= size.height);
      assert.ok(rect.x >= 0 && rect.x + rect.width <= size.width);
      await page.screenshot({ path: 'output/qa/workspace-confirmation-' + size.width + '.png' });
    }
    await page.setViewportSize({ width: 390, height: 844 });
    await click('Modifier mon choix');
    assert.equal(await workspace(), null);
    await choose('Agriculteur');
    await click('Modifier mon choix');
    await choose('Acheteur');
    await click('Entrer dans mon espace');
    await button('Profil').waitFor();
    assert.equal((await workspace()).lastRoles['+221771234567'], 'buyer');
    await logout();
    await page.reload();
    await semantics();
    await login();
    await button('March\u00e9').waitFor();
    assert.equal(await button(/^Acheteur/).count(), 0);
    assert.ok(page.url().endsWith('#/home'));
    restored.push('buyer after reload');

    for (const [name, role, tab] of [
      ['Agriculteur', 'farmer', 'R\u00e9coltes'],
      ['Prestataire', 'provider', 'Services'],
      ['Investisseur', 'investor', 'Projets'],
    ]) {
      await click('Profil');
      await click(/^Changer d\u2019espace/);
      await button(/^Retour/).waitFor();
      await click(/^Retour/);
      await click(/^Changer d\u2019espace/);
      await choose(name);
      await click('Entrer dans mon espace');
      await button(tab).waitFor();
      assert.equal((await workspace()).lastRoles['+221771234567'], role);
      await logout();
      await login();
      await button(tab).waitFor();
      assert.equal(await button('Continuer').count(), 0);
      assert.ok(page.url().endsWith('#/home'));
      restored.push(role);
    }
    await page.screenshot({ path: 'output/qa/workspace-restored-investor.png' });
    await logout();
    await login('78 123 45 67');
    await button(/^Acheteur/).waitFor();
    assert.ok(await button('Continuer').isDisabled());
    assert.equal((await workspace()).lastRoles['+221781234567'], undefined);
    assert.deepEqual(errors, []);
    console.log(JSON.stringify({ success: true, restored, otherPhoneRequiresChoice: true, errors }));
  } catch (error) {
    await page.screenshot({ path: 'output/qa/workspace-failure.png' });
    console.error(await page.locator('body').ariaSnapshot());
    throw error;
  } finally {
    await browser.close();
  }
})().catch(error => { console.error(error); process.exitCode = 1; });
