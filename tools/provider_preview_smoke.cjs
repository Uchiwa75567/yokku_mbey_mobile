const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const assert = require('node:assert/strict');
const fs = require('node:fs/promises');

(async () => {
  const browser = await chromium.launch({ channel: 'msedge', headless: true });
  const page = await browser.newPage({ viewport: { width: 390, height: 844 }, deviceScaleFactor: 1 });
  page.setDefaultTimeout(20000);
  const errors = [];
  page.on('pageerror', error => errors.push(error.message));
  const capture = async name => {
    await page.waitForTimeout(400);
    await page.screenshot({ path: 'output/qa/services-browser-' + name + '.png' });
  };
  const click = async label => {
    await page.getByRole('button', { name: label, exact: true }).first().click();
    await page.waitForTimeout(450);
  };
  const workspace = () => page.evaluate(() => {
    const value = Object.entries(localStorage).find(([key]) => key.includes('yokku_mbey.demo.workspace'));
    if (!value) throw new Error('Missing local workspace');
    let parsed = JSON.parse(value[1]);
    if (typeof parsed === 'string') parsed = JSON.parse(parsed);
    return parsed;
  });
  const fill = async (index, value) => {
    await page.getByRole('textbox').nth(index).click();
    await page.waitForTimeout(120);
    await page.keyboard.press('Control+A');
    await page.keyboard.insertText(value);
    await page.waitForTimeout(120);
  };
  let hasChosenRole = false;
  const login = async role => {
    await page.getByRole('textbox').first().waitFor();
    await page.waitForTimeout(500);
    await page.getByRole('textbox').first().fill('77 123 45 67');
    await click('Continuer');
    for (const digit of ['1', '2', '3', '4']) {
      await page.getByRole('button', { name: new RegExp('^Chiffre ' + digit) }).click();
    }
    if (hasChosenRole) {
      await click('Profil');
      await click('Changer d’espace');
    }
    await page.getByRole('button', { name: new RegExp('^' + role) }).click();
    await click('Continuer');
    await click('Entrer dans mon espace');
    hasChosenRole = true;
    await page.getByRole('button', { name: 'Profil', exact: true }).waitFor();
  };
  const logout = async () => {
    for (let i = 0; i < 8 && !await page.getByRole('button', { name: 'Profil', exact: true }).count(); i++) {
      await click(/^Retour/);
    }
    await click('Profil');
    await click('Se déconnecter');
    await click('Se déconnecter');
    await page.getByRole('button', { name: 'Continuer', exact: true }).waitFor();
  };
  try {
    await fs.mkdir('output/qa', { recursive: true });
    await page.goto(process.argv[2] || 'http://127.0.0.1:8091', { waitUntil: 'domcontentloaded' });
    const semantics = page.locator('flt-semantics-placeholder');
    await semantics.waitFor({ state: 'attached', timeout: 30000 });
    await semantics.evaluate(node => node.click());
    await page.getByRole('button', { name: /Passer/ }).click();
    await login('Prestataire');
    await capture('provider-home');
    await click('Ajouter un service');
    await fill(0, 'Tracteur QA avec conducteur');
    await page.getByRole('button', { name: 'Catégorie Transport', exact: true }).click();
    await page.getByRole('menuitem', { name: 'Tracteur', exact: true }).click();
    await page.waitForTimeout(500);
    await fill(1, '40000');
    await fill(2, 'Labour avec conducteur et charrue. Carburant inclus.');
    const chooserPromise = page.waitForEvent('filechooser');
    await click('Choisir une photo');
    const chooser = await chooserPromise;
    await chooser.setFiles('assets/images/service_tractor_demo.png');
    await page.getByRole('button', { name: 'Supprimer la photo 1', exact: true }).waitFor();
    await capture('photo-upload');
    await click('Publier le service');
    await page.getByText('Mes offres', { exact: true }).waitFor();
    let data = await workspace();
    let service = data.accounts['+221771234567:provider'].records.find(r => r.kind === 'service');
    assert.equal(service.photos.length, 1);
    assert.ok(service.photos[0].startsWith('data:image/jpeg'));
    await capture('published-offer');
    await logout();
    await login('Agriculteur');
    await page.getByRole('button', { name: /^Travail et matériel/ }).click();
    await page.getByRole('button', { name: /Tracteur QA avec conducteur/ }).waitFor();
    await capture('farmer-directory');
    await page.getByRole('button', { name: /Tracteur QA avec conducteur/ }).click();
    await capture('farmer-tractor');
    await click('Demander cette prestation');
    await fill(0, '2');
    await fill(1, 'Champ accessible près de Thiès. Labour de deux parcelles.');
    await click('Envoyer ma demande');
    await page.getByText('Suivi de la prestation', { exact: true }).waitFor();
    data = await workspace();
    let request = data.accounts['+221771234567:farmer'].records.find(r => r.kind === 'job');
    assert.equal(request.amount, 80000);
    assert.equal(request.status, 'pending');
    await capture('farmer-request');
    await logout();
    await login('Prestataire');
    await click('Missions');
    await page.getByRole('button', { name: /Tracteur QA avec conducteur/ }).click();
    await click('Accepter la demande');
    await click('Démarrer la mission');
    await click('Terminer la mission');
    data = await workspace();
    assert.equal(data.accounts['+221771234567:farmer'].records.find(r => r.id === request.id).status, 'completed');
    assert.equal(data.accounts['+221771234567:provider'].records.find(r => r.id === request.id).status, 'completed');
    await capture('mission-completed');
    await logout();
    await login('Investisseur');
    await capture('investor-home');
    await click('Voir les projets');
    await page.getByRole('group', { name: /Irrigation des Niayes/ }).click();
    await capture('investor-project');
    await page.setViewportSize({ width: 1440, height: 960 });
    await capture('investor-desktop');
    await page.setViewportSize({ width: 390, height: 844 });
    await click('Soutenir ce projet');
    await fill(0, '100000');
    await page.getByRole('checkbox').click();
    await page.getByRole('checkbox', { checked: true }).waitFor();
    await click('Enregistrer mon intention');
    await page.getByRole('button', { name: 'Retirer mon intention', exact: true }).waitFor();
    data = await workspace();
    const intention = data.accounts['+221771234567:investor'].records.find(r => r.kind === 'investment');
    assert.equal(intention.amount, 100000);
    assert.equal(intention.status, 'pending');
    await capture('investor-intention');
    await logout();
    await login('Investisseur');
    await click('Suivi');
    await page.getByRole('button', { name: /Irrigation des Niayes/ })
      .or(page.getByRole('group', { name: /Irrigation des Niayes/ })).first().waitFor();
    await capture('investor-funding');
    assert.equal(errors.length, 0, errors.join('\n'));
    console.log(JSON.stringify({ success: true, checks: ['photo upload and storage', 'farmer catalogue', 'shared mission lifecycle', 'investor intention', 'mobile and desktop screenshots'], errors }));
  } catch (error) {
    await capture('failure');
    console.error(await page.locator('body').ariaSnapshot());
    throw error;
  } finally {
    await browser.close();
  }
})().catch(error => { console.error(error); process.exitCode = 1; });
