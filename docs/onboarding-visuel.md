# Splash et onboarding

Le splash utilise de nouveau le visuel original `assets/images/splash_screen.png`, sans modification du fichier ni recadrage du logo. La duree existante de 700 ms et la transition de 250 ms sont conservees.

L'onboarding utilise des illustrations de personnages, un fond blanc, des titres centres, une progression en trois etapes, un retour et un acces direct a la connexion. Les deuxieme et troisieme illustrations sont les fichiers originaux `splash_screen_2.png` et `splash_screen_3.png`.

La nouvelle declinaison du premier personnage est sauvegardee dans `assets/images/onboarding_farmer_light.png`. Le fichier original `splash_screen_1.png` reste intact.

## Generation de l'illustration

Outil : image_gen integre, sans CLI. Cible : splash_screen_1.png. Reference de style : splash_screen_2.png.

Prompt utilise :

> Use case: style-transfer. Asset type: mobile agriculture application onboarding illustration, no UI, no text. Image 1 is the edit target. Image 2 is the style reference only. Preserve the smiling Senegalese farmer from Image 1, his straw hat, green shirt, hands holding the full wooden crate of mixed vegetables. Change the dark green/yellow vignette and hazy background to a pure white background with a few very pale green botanical leaves and simple low farm rows, matching the clean bright illustrated style of Image 2. Keep the same farmer identity and pose from Image 1. Render as polished 2D raster illustration with clean contours and warm natural skin tones; not photorealistic. Square composition, medium shot from hat to just below crate, whole hat, both arms, hands and entire crate visible, character large and centered with modest white margins. Keep all four outer edges white so it integrates naturally into a white app. No glow, no vignette, no gradient background, no lettering, no frame, no rounded rectangle, no extra people. This is a new sibling asset; do not modify the original splash screen image.
