# Prestataire et investisseur

## Prestataire

Le formulaire distingue **Technique** et **Ouvrier**. Un ouvrier peut travailler seul ou en equipe ; son tarif concerne l'equipe entiere. Competences, experience, zone, date de disponibilite et travaux sont visibles dans sa fiche. Les unites sont controlees selon le type.

Une location de tracteur ou de materiel demande au moins une photo de l'equipement. Camera et galerie utilisent image_picker. Les photos sont conservees dans l'offre, modifiables et visibles par l'agriculteur. La galerie de detail affiche l'image entiere sans recadrer le materiel.

Le catalogue ne diffuse que les offres actives. Les anciennes offres de materiel sans photo doivent etre completees avant d'y apparaitre. Les exemples ne peuvent recevoir aucune demande. Les devis repondant aux besoins d'exemple ne peuvent pas etre auto-approuves.

Une demande directe contient une copie du tarif, de l'unite, de la quantite, du total, de la date et du travail demande. Une modification ulterieure du prix de l'offre ne modifie pas la demande.

- Agriculteur : demande en attente, annulable avant acceptation.
- Prestataire : accepte ou refuse une demande en attente ; demarre une mission acceptee ; termine une mission en cours.
- Les deux copies sont enregistrees dans une seule ecriture locale. En cas d'echec, aucun des deux statuts ne change.
- Une seule demande ouverte par agriculteur et offre. Quantite de 1 a 365 unites, date dans les 365 prochains jours, respect de la disponibilite annoncee.

## Photos

Trois photos au maximum, fichier source limite a 12 Mo et 24 megapixels avant decodage complet. Chaque photo est orientee, limitee a 960 pixels sur son plus grand cote, convertie en JPEG et limitee a 400 Ko. Une nouvelle image sans metadonnees est creee pour ne pas conserver la localisation EXIF. Le JSON stocke les images en URI de donnees : aucune dependance a un fichier temporaire du telephone.

Les descriptions d'autorisation camera et phototheque sont presentes sur iOS ; macOS dispose de l'autorisation de lecture des fichiers choisis. Sur Android, une photo interrompue par la destruction de l'activite peut etre recuperee en rouvrant le formulaire. Les champs non publies ne constituent pas encore un brouillon persistant.

Reference : [documentation officielle image_picker](https://pub.dev/packages/image_picker). Sur ordinateur, la galerie est proposee ; le bouton camera est reserve au mobile et au web. Sur le web, le comportement du bouton camera depend du navigateur. Les autorisations et la capture sur un vrai telephone restent a valider sur appareil.

Le stockage est une demonstration SharedPreferences, pas un stockage de medias de production. Sa capacite depend de la plateforme, notamment du quota du navigateur. Une erreur de quota est signalee sans remplacer les donnees en memoire par une sauvegarde manquee. Avant production : stockage objet, serveur transactionnel, moderation et regles de conservation.

## Investisseur

Accueil avec projet illustre et acces au suivi, fiches avec objectif, budget detaille, calendrier previsionnel et beneficiaires vises. Le formulaire controle le minimum, le plafond et le consentement. Le suivi filtre les intentions et calcule leur total en attente.

Les projets restent des exemples. Aucun contrat, paiement ou rendement n'est cree ; une intention n'augmente pas le financement affiche. Les impacts sont des objectifs, pas des resultats acquis. L'intention peut etre retiree tant qu'elle est en attente.

## Partage local

Les offres actives sont consultables entre comptes prestataire et agriculteur du meme navigateur/appareil. Les autres donnees privees du prestataire ne sont pas ajoutees au catalogue. Les demandes ne sont accessibles qu'aux deux comptes participants dans l'application. Cela ne remplace pas une autorisation serveur : l'OTP reste 1234 en demonstration.

Pas de synchronisation entre appareils ou onglets ouverts simultanement, de paiement, ni de messagerie reelle. L'onboarding et le splash d'origine ne sont pas modifies par cette refonte.

## Verification

Tests de regles : test/provider_marketplace_test.dart. Tests de formulaire, photos et mission partagee : test/provider_journey_test.dart. Les captures mobiles et desktop avec texte agrandi sont produites par test/journey_layout_test.dart. Le controle navigateur est dans tools/provider_preview_smoke.cjs.

## Visuel d'exemple

- Fichier : assets/images/service_tractor_demo.png
- Outil : outil integre image_gen.imagegen, generation initiale.
- Usage : illustration fictive, etiquetee **Exemple** ; jamais substituee automatiquement a la photo d'un prestataire.
- Prompt :

> Use case: product-mockup. Asset type: agricultural equipment marketplace DEMO listing photograph, landscape 3:2. A realistic clean green utility tractor with a red plough attachment parked on a flat dry farm track beside cultivated green fields in rural Senegal. Three-quarter front view, whole tractor including all wheels, cabin, and attachment clearly visible with comfortable framing margins. Bright natural daylight, neutral color balance, crisp inspection-quality detail, no blur, no dramatic sunset. Simple authentic farmland background, no people, no text, no logos, no watermark. This fictional equipment picture will be explicitly labeled as a demo example, not as an actual user's machine.
