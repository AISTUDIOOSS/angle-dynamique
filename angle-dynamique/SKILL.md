---
name: angle-dynamique
description: |-
  Rend une vidéo IA dynamique avec des angles de caméra « fausse vidéo amateur 2005 » : caméra levée, crash zoom, GoPro fisheye, whip pan, secousses, plans qui changent toutes les 2 secondes. Prend une vidéo, une idée ou un prompt, réécrit le prompt plan par plan pour Seedance, Kling, Veo ou Higgsfield, et donne les effets à ajouter au montage. À utiliser pour « angle dynamique », « caméra amateur », « crash zoom », « whip pan », « style GoPro », « vidéo trop propre / trop plate », ou une pub IA qui doit avoir du peps.
---

# Angle dynamique

Le problème de la plupart des vidéos IA : une caméra qui ne bouge pas, des plans tout propres, des angles nuls. Résultat : c'est chiant, même quand l'idée est bonne.

La recette de ce skill : filmer un truc absurde **comme si quelqu'un l'avait vraiment filmé**, sans l'avoir prévu, avec une caméra pas chère de 2005. Rien ne doit ressembler à du cinéma. Elle vient d'une pub de Noël IA (père Noël gangsta dans l'espace) refaite plusieurs fois jusqu'à ce que ça marche ; les erreurs corrigées en route sont dans les règles ci-dessous.

Fichiers à lire au besoin :
- `references/mouvements.md` : les 17 mouvements, leur vrai nom et les mots à mettre dans le prompt.
- `references/prompt-modele.md` : le modèle de prompt qui a marché, à remplir.
- `references/montage.md` : faire les mouvements au montage (crash zoom, punch-in, whip, secousse) et la couche « vidéo 2005 ».
- `scripts/couche-2005.sh` : applique la couche 2005 à une vidéo finie.

## Étape 1 : comprendre ce qu'on te donne

Demande seulement ce qui manque, en une question à la fois :
- **Une vidéo** à rendre dynamique, **une idée** de scène, ou **un prompt** déjà écrit.
- **L'outil** de génération (Seedance, Kling, Veo, Sora, Higgsfield…). Par défaut : Seedance.
- **Le format** : 9:16 (Reel, TikTok) ou 4:3 / 16:9. Le look 2005 marche très bien en 4:3.
- **Les personnages et objets récurrents**, et s'il a des fiches (images de référence) pour eux.

Si on te donne une vidéo, regarde-la vraiment avant d'écrire quoi que ce soit :

```bash
ffmpeg -i video.mp4 -vf "fps=2,scale=360:-2,tile=6x6" -frames:v 1 planche.jpg
ffmpeg -i video.mp4 -vf "select='gt(scene,0.12)',showinfo" -f null - 2>&1 | grep -o "pts_time:[0-9.]*"
```

La première commande fait une planche d'images (une image toutes les 0,5 s), la seconde donne le moment de chaque coupe. Liste les plans avec leur durée et repère ceux qui sont plats : caméra fixe sans raison, cadrage de face et centré, plan de plus de 4 s où rien ne change, rendu trop propre.

Ensuite deux chemins :
- **Il veut regénérer** : passe aux étapes 2 à 4, puis donne-lui le nouveau prompt.
- **Il garde ses images** : passe directement à l'étape 5 et ajoute les mouvements au montage.

## Étape 2 : choisir le look

| Look | À quoi ça ressemble | Mots du prompt |
|---|---|---|
| **A. GoPro** | Grand angle déformé, coins sombres, lampe ou flash sur la caméra, image molle, noirs bouchés | `cheap GoPro HERO, wide-angle distortion, on-camera light, soft compressed low-res image, crushed blacks` |
| **B. Caméscope 2005** | Pas de grand angle, lumière dure ou néon plat, tout est net de près comme de loin, un peu saturé, image baveuse, des gens qui réagissent | `mid-2000s consumer camcorder, flat harsh light, deep focus, slightly oversaturated, soft low-res, no cinematic grade` |

Un seul look par plan. Une vidéo peut passer de A à B d'un plan à l'autre (par exemple la GoPro de l'astronaute, puis un plan large filmé de loin au caméscope).

## Étape 3 : découper en plans

Règles mesurées sur des vidéos qui marchent :
- **Il se passe un truc toutes les 2 à 2,5 secondes.** C'est la règle qui change tout. Un plan dure 2 à 4 s, jamais plus, avec un seul événement.
- **Un mouvement nommé par plan**, pris dans `references/mouvements.md`. Varie : ne mets pas deux crash zooms de suite.
- **Chaque plan monte d'un cran** dans le n'importe quoi. Le personnage principal reste calme et joue « normal » ; les gens autour réagissent pour de vrai.
- **Les coupes sont cachées** : dans un whip pan, une secousse, un objet qui passe devant l'objectif, de la fumée qui bouche l'image. Peu de coupes franches.
- **Jamais de face et centré.** De biais, de côté, un peu de dos, cadrage de travers. C'est l'erreur qui revient le plus souvent, et l'IA y retombe dès qu'on oublie de l'écrire.

Présente le découpage sous forme de tableau avant d'écrire le prompt :

| # | Temps | Ce qu'on voit | Mouvement | Où il se fait (IA ou montage) |
|---|---|---|---|---|

Attends son OK sur ce tableau : c'est là qu'il change d'avis, pas après une génération payante.

## Étape 4 : écrire le prompt

Pars de `references/prompt-modele.md`. Les règles qui ont fait la différence :

1. **Les mots de caméra au début** de chaque plan : `SHOT 2 (2.5-5s) - Long lens, handheld.` L'IA respecte mieux un mouvement annoncé en premier.
2. **Joindre toutes les fiches de référence**, une par personnage, objet ou décor qui revient (personnage de face et de profil, véhicule, lieu). Quand il en manque une, l'élément dérive d'un plan à l'autre. Les images clés, elles, servent à valider l'idée mais sont à éviter dans l'envoi final : l'IA les recopie trop et perd le mouvement.
3. **Nommer chaque personnage dans CHARACTERS**, y compris les secondaires, avec ce qui doit rester vrai : « pulled by its reindeer, always visible in front of the sleigh ». Un personnage pas nommé finit par disparaître.
4. **Écrire « nothing is ever framed face-on »** dans le style global, et le redire dans les plans à risque.
5. **Crash zoom = vrai zoom d'objectif, caméra immobile** : `real optical zoom, the camera does not move forward`. Sinon l'IA fait avancer la caméra et ça devient un travelling propre.
6. **Le mot « fisheye »** fait parfois apparaître un rond noir dans l'image (Seedance surtout). Préfère `wide-angle distortion` ; garde `fisheye, circular black vignette` seulement si le rond est voulu.
7. **Une chose à la fois** : si une action crée un effet non voulu (« crash zoom sur sa main et la télécommande » lui fait tendre la télécommande face caméra), décris la pose voulue (« seen from the side, presses it without looking »).
8. **Mots interdits** : `cinematic`, `smooth`, `dolly`, `drone`, `gimbal`, `4K`, `epic`, `masterpiece`. Ils rendent l'image propre.
9. **Son réel, pas de musique** : moteurs, coups, cris, souffle. Ni texte ni logo dans l'image, sauf s'il les veut.
10. **Pas de génération sans son accord** : annonce l'outil, la durée et le coût, puis attends son oui.

Si la vidéo est longue (plus de 10 à 12 s), coupe-la en parties de 2 à 4 plans, avec les mêmes fiches. Pour rallonger la fin d'un plan, utilise le mode « prolonger la vidéo » de l'outil plutôt qu'un nouveau prompt.

## Étape 5 : le montage

L'IA rend presque toujours une image trop nette. Le look amateur se finit au montage (détails et commandes dans `references/montage.md`) :
- **Crash zoom, punch-in, whip pan, secousses** : plus fiables au montage que demandés à l'IA.
- **Secousses calées sur le son** : chaque impact (coup, toc toc, explosion) = 6 à 10 images de secousse.
- **Couche « vidéo 2005 » sur la vidéo finie, toujours** : `scripts/couche-2005.sh video.mp4`. Elle réduit l'image puis l'agrandit, ajoute du bruit et un léger flou, et réencode en qualité basse.

## Avant de rendre

Regarde une image par plan (planche de l'étape 1) et vérifie :
- Aucun plan ne ressemble à un film ou à une image 3D. Sinon il manque la couche 2005, un cadrage de travers ou une secousse.
- Aucun plan de face et centré.
- Il se passe quelque chose toutes les 2 à 2,5 s.
- Les personnages et objets récurrents sont les mêmes d'un plan à l'autre.

Dis ce qui reste raté, plan par plan, au lieu d'annoncer que tout est parfait.
