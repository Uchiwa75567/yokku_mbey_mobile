const { chromium } = require(process.env.PLAYWRIGHT_MODULE || 'playwright');
const fs = require('node:fs/promises');

(async () => {
  const browser = await chromium.launch({ channel: 'msedge', headless: true });
  let page;
  try {
    page = await browser.newPage({ viewport: { width: 390, height: 844 }, deviceScaleFactor: 1 });
    page.setDefaultTimeout(15000);
    const errors = [];
    page.on('pageerror', error => errors.push(error.message));
    await page.goto(process.argv[2] || 'http://127.0.0.1:8091', { waitUntil: 'domcontentloaded' });
    await page.locator('flt-semantics-placeholder').waitFor({ state: 'attached', timeout: 20000 });
    await page.locator('flt-semantics-placeholder').evaluate(node => node.click());
    await page.getByRole('button', { name: /Passer/ }).waitFor();
    await fs.mkdir('output/qa', { recursive: true });
    await page.screenshot({ path: 'output/qa/browser-start.png' });
    await page.getByRole('button', { name: 'Suivant', exact: true }).click();
    await page.waitForTimeout(450);
    await page.screenshot({ path: 'output/qa/browser-onboarding-2.png' });
    await page.getByRole('button', { name: 'Étape précédente', exact: true }).click();
    await page.waitForTimeout(350);
    await page.getByRole('button', { name: 'Suivant', exact: true }).click();
    await page.waitForTimeout(350);
    await page.getByRole('button', { name: 'Suivant', exact: true }).click();
    await page.waitForTimeout(450);
    await page.screenshot({ path: 'output/qa/browser-onboarding-3.png' });
    await page.getByRole('button', { name: 'Commencer', exact: true }).click();
    const capture = async name => {
      await page.waitForTimeout(400);
      await page.screenshot({ path: `output/qa/browser-${name}.png` });
    };
    let hasChosenRole = false;
    const signIn = async (role, name) => {
      await page.getByRole('textbox').first().fill('77 123 45 67');
      await page.getByRole('button', { name: 'Continuer', exact: true }).click();
      await page.getByRole('button', { name: /^Chiffre 1/ }).waitFor();
      if (name === 'buyer') await capture('otp');
      for (const digit of ['1', '2', '3', '4']) {
        await page.getByRole('button', { name: new RegExp(`^Chiffre ${digit}`) }).click();
      }
      if (hasChosenRole) {
        await page.getByRole('button', { name: 'Profil', exact: true }).click();
        await page.getByRole('button', { name: /^Changer d’espace/ }).click();
        await page.waitForTimeout(450);
      }
      await page.getByRole('button', { name: role }).click();
      if (name === 'buyer') await capture('roles');
      await page.getByRole('button', { name: 'Continuer', exact: true }).click();
      await page.getByRole('button', { name: 'Entrer dans mon espace', exact: true }).click();
      hasChosenRole = true;
      await page.getByRole('button', { name: 'Profil', exact: true }).waitFor();
      await capture(`${name}-home`);
    };
    const signOut = async () => {
      await page.getByRole('button', { name: 'Profil', exact: true }).click();
      const button = page.getByRole('button', { name: 'Se déconnecter', exact: true });
      await button.click();
      await button.click();
      await page.getByRole('button', { name: 'Continuer', exact: true }).waitFor();
      // Wait for the outgoing route to finish its transition before typing again.
      await page.waitForTimeout(450);
    };
    await capture('login');
    await signIn(/^Acheteur/, 'buyer');
    await page.getByRole('button', { name: 'Marché', exact: true }).click();
    await page.getByText('Le marché', { exact: false }).waitFor();
    await page.waitForTimeout(500);
    await page.screenshot({ path: 'output/qa/browser-buyer-market.png' });
    await page.setViewportSize({ width: 1440, height: 1000 });
    await page.waitForTimeout(500);
    await page.screenshot({ path: 'output/qa/browser-buyer-desktop.png' });
    await page.setViewportSize({ width: 390, height: 844 });
    await page.getByRole('group', { name: /^Tomate fraîche Kaolack/ }).click();
    await page.getByText('Détail du produit', { exact: true }).waitFor();
    await capture('buyer-product');
    await page.getByRole('button', { name: 'Augmenter la quantité', exact: true }).click();
    await page.mouse.move(180, 650);
    await page.mouse.wheel(0, 520);
    await page.waitForTimeout(400);
    await page.getByRole('checkbox').check();
    await capture('buyer-reservation');
    await page.getByRole('button', { name: 'Demander une réservation', exact: true }).click();
    await page.getByText('Réservation enregistrée', { exact: true }).waitFor();
    await capture('buyer-confirmation');
    await page.getByRole('button', { name: 'Voir mes achats', exact: true }).click();
    await signOut();
    for (const [role, name, tab] of [
      [/^Investisseur/, 'investor', 'Projets'],
      [/^Prestataire/, 'provider', 'Services'],
      [/^Agriculteur/, 'farmer', 'Récoltes'],
    ]) {
      await signIn(role, name);
      await page.getByRole('button', { name: tab, exact: true }).click();
      await capture(`${name}-catalogue`);
      await signOut();
    }
    if (errors.length) throw new Error(errors.join('\n'));
    console.log(JSON.stringify({ journey: 'onboarding / login / OTP / roles / buyer reservation / four profiles and logout', errors }));
  } catch (error) {
    if (page) {
      await page.screenshot({ path: 'output/qa/browser-failure.png' });
      console.error(await page.locator('body').ariaSnapshot());
    }
    throw error;
  } finally {
    await browser.close();
  }
})().catch(error => { console.error(error); process.exitCode = 1; });
