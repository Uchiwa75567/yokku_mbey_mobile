# Yokku Mbey

Application Flutter pour les acteurs agricoles : agriculteur, acheteur, investisseur et prestataire.

Interface blanche et verte commune aux quatre profils, de l'onboarding aux formulaires et au suivi. Le catalogue acheteur et la reservation integree reprennent la maquette validee.

## Structure

- `lib/app` : composition de l'application et routage initial.
- `lib/core` : theme, constantes et fondations reutilisables.
- `lib/features` : modules fonctionnels independants.

## Lancement

```sh
flutter pub get
flutter run
```

La version actuelle fonctionne en demonstration avec sauvegarde locale. Saisir un numero mobile senegalais valide, puis le code **1234** et choisir un profil. Aucun SMS ou paiement reel n'est effectue. Chaque profil dispose d'une option de deconnexion.

Les parcours acheteur, investisseur et prestataire sauvegardent leurs donnees sur l'appareil. Le catalogue de travail et materiel relie maintenant prestataires et agriculteurs du meme appareil : offres d'ouvriers ou prestations techniques, photos, demandes et suivi de mission. Les autres ecrans agriculteur restent en partie des maquettes interactives.

La [refonte prestataire et investisseur](docs/prestataire-investisseur.md) detaille les photos, le partage local et les limites avant mise en production.

Les parcours actifs, les regles metier et les integrations externes restantes sont detailles dans [la documentation des parcours](docs/parcours-et-logique-metier.md).

```sh
flutter analyze --no-pub
flutter test --no-pub
```
