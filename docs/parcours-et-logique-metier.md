# Parcours Yokku Mbey

## Version locale

Les parcours actifs passent par `AppRoutes`. La refonte reprend la maquette validee : fond blanc, vert profond, texte sombre, photos des produits, bordures discretes et navigation basse commune. Les routes acheteur utilisent les vues de `features/buyer` et `features/account`. Les anciennes classes d'ecrans acheteur restent disponibles comme references, mais leurs maquettes de paiement et leurs donnees statiques ne sont plus utilisees par le routage de l'application.

Les parcours investisseur et prestataire sont dans `features/stakeholders`. Les quatre profils utilisent les composants clairs de `JourneyScaffold`. Toutes les barres de navigation reutilisent `FarmerBottomNavigation`, avec les destinations propres au role. L'onboarding, la connexion, l'OTP et le choix du profil partagent cette direction visuelle. Les pages defilent et les formulaires s'adaptent au clavier ; le catalogue utilise deux colonnes sur mobile et trois sur grand ecran.

## Agriculteur

L'accueil, les recoltes, la publication, l'edition, les stocks, le boost, les reservations, les avis et les pages du profil ont ete harmonises. Leurs donnees et plusieurs actions restent des exemples locaux non persistants, independants du catalogue acheteur. Une reservation acheteur ne parvient pas encore a un compte agriculteur.

Le nouveau catalogue **Travail et materiel**, accessible depuis l'accueil et le profil, affiche les offres actives des prestataires du meme appareil, avec leurs photos. L'agriculteur filtre les ouvriers et prestations, consulte competences, disponibilites et tarifs, puis envoie une demande et suit son statut. Cette partie est persistante. Le stockage de photos des recoltes, les paiements et la synchronisation distante restent a connecter.

## Acheteur

- Accueil, categories, catalogue, recherche par produit/producteur, region, disponibilite et prix.
- Detail du produit avec reservation integree, favoris, controle du minimum et du stock restant, boutons de quantite bornes et total recalcule.
- Retrait ou livraison avec adresse obligatoire et copie de l'adresse dans la reservation.
- Confirmation locale, liste des achats, detail et suivi, annulation tant que le producteur n'a pas confirme.
- Publication, modification et cloture des besoins ; offres correspondantes du catalogue.
- Profil modifiable, adresses, alertes avec correspondances locales, avis sur achats termines, signalements locaux.

## Investisseur

- Accueil, recherche des projets par region/categorie, detail du budget, usage des fonds et objectifs.
- Intention de financement avec montant minimum/maximum, consentement et message.
- Une seule intention ouverte par projet ; retrait possible tant qu'elle est en attente.
- Suivi des intentions et des objectifs des projets. Une intention ne modifie pas le montant collecte et n'est jamais presentee comme un paiement ou un impact realise.

## Prestataire

- Accueil illustre, publication et modification de deux types d'offres : travail agricole (ouvrier seul ou equipe) et prestation technique.
- Competences/experience, taille d'equipe, disponibilite, region, tarif et unite adaptes au type.
- Prise ou selection de photos, apercu et suppression. Une photo au minimum est obligatoire pour Tracteur et Materiel ; trois au maximum par offre.
- Mise en pause et reactivation des offres.
- Recherche et detail des demandes, devis lie a un service actif de la meme categorie.
- Un devis ouvert par demande ; retrait possible avant accord du client.
- Une demande directe de l'agriculteur est enregistree dans les deux comptes locaux. Le prestataire accepte ou refuse, puis demarre et termine la mission. L'agriculteur peut annuler avant acceptation.
- Les devis lies aux besoins d'exemple restent en attente : le prestataire ne peut pas approuver son propre devis.
- Contacts derives de ses devis et missions.

## Donnees et session

`MarketplaceStore` centralise les regles et expose des enregistrements immuables. Les ecritures sont serialisees ; l'etat visible ne change qu'apres la sauvegarde. Les erreurs de stockage sont affichees et une sauvegarde en retard ne reconnecte jamais un utilisateur deconnecte.

`WorkspacePersistence` isole le stockage. `LocalWorkspacePersistence` utilise SharedPreferencesAsync pour cette demonstration locale ; `MemoryWorkspacePersistence` permet les tests. Le format JSON est versionne. Les donnees sont separees par numero et role. Le stock local prend en compte les reservations des autres comptes de l'appareil sans exposer leurs informations.

Le code de demonstration est **1234**. Les numeros sont valides, les codes expirent apres cinq minutes, le renvoi attend une minute et cinq tentatives incorrectes bloquent la verification jusqu'a un nouveau code. Il ne s'agit pas d'une authentification reelle. Aucun jeton de connexion n'est conserve. Apres relance, l'utilisateur se reconnecte pour retrouver ses donnees locales.

La deconnexion est accessible depuis les quatre profils. Elle efface la session et la pile de navigation. Les routes privees et les actions metier verifient le profil connecte.

Au premier choix, aucun espace n'est preselectionne. Un panneau recapitulatif permet de confirmer ou de modifier le choix ; fermer ce panneau ne l'enregistre pas. Le dernier espace confirme est sauvegarde par numero de telephone, meme sans annonce ni commande. Apres validation de l'OTP, les connexions suivantes ouvrent directement cet espace, sans repasser par la selection. Cela ne conserve pas une session authentifiee et reste limite au stockage de cet appareil.

L'action **Changer d'espace** est presente dans les quatre profils. Elle conserve la session, demande confirmation et charge uniquement les donnees de l'espace choisi, sans effacer celles des autres. Le retour annule le changement ; une confirmation reussie remplace la pile de navigation. Un echec de sauvegarde conserve l'espace precedent. Pour les anciennes donnees sans preference, un seul espace existant est retrouve automatiquement ; si plusieurs existent, le choix reste explicite.

## Connexions externes restantes

Le depot ne contient pas de backend Node/Supabase ni d'identifiants de fournisseur d'authentification. Les SMS, la diffusion distante des annonces, les notifications distantes et les paiements ne sont pas connectes. Seules les demandes directes de prestation relient actuellement deux acteurs, sur le meme appareil. Les annonces et projets d'exemple sont fictifs ; les offres effectivement publiees en sont distinguees.

Voir [les regles de la refonte prestataire et investisseur](prestataire-investisseur.md), dont les limites du stockage de photos.

Une mise en production demande une authentification serveur, des autorisations par compte, un stockage serveur transactionnel (notamment pour les stocks et statuts), les notifications et les integrations de contact. Le stockage local de demonstration ne doit pas servir de registre financier ni d'autorisation de production.

## Verification

- `flutter analyze --no-pub`
- `flutter test --no-pub` : tests existants, regles metier, parcours par profil, deconnexion et routage protege.
- `test/journey_layout_test.dart` : ecrans mobiles et desktop avec texte agrandi, captures dans `output/qa`.
- `test/auth_redesign_layout_test.dart` : onboarding, connexion, OTP, profils et formulaire avec clavier ouvert, en 320, 390 et 1440 pixels.
- `node tools/preview_smoke.cjs` : controle web dans Edge via Playwright, connexion, catalogue et deconnexion des profils.
- `flutter build web --no-pub --no-wasm-dry-run` : polices et CanvasKit servis localement.
