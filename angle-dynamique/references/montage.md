# Les mouvements au montage

Plus fiables que de les demander à l'IA. Les réglages marchent dans Premiere, CapCut, DaVinci ou Final Cut ; les commandes FFmpeg font la même chose sans logiciel de montage (FFmpeg doit être installé : `brew install ffmpeg` sur Mac).

## Crash zoom

Échelle de 100 % à 180–250 % en 4 à 6 images, accélération à l'entrée, flou radial (zoom blur) sur ces images, puis 2 à 3 images de secousse à l'arrêt.

```bash
# Zoom de l'image 24 à l'image 29 (à 24 images/s : de 1 s à 1,2 s), jusqu'à x2,2.
# Remplace 720x540 par la taille de ta vidéo et 24 par sa cadence.
ffmpeg -i in.mp4 -vf "zoompan=z='if(lt(in,24),1,if(lt(in,29),1+1.2*(in-24)/5,2.2))':x='iw/2-(iw/zoom/2)':y='ih/2-(ih/zoom/2)':d=1:s=720x540:fps=24" -c:a copy crash-zoom.mp4
```

Pour zoomer ailleurs qu'au centre, remplace `iw/2` et `ih/2` par la position du sujet en pixels.

## Punch-in

Coupe le plan en deux au même endroit ; agrandis la seconde moitié à 200–300 %. La perte de netteté est une bonne chose : ça fait zoom numérique pas cher.

## Whip pan entre deux plans

Déplacement de 1 à 2 largeurs d'écran en 4 à 6 images, avec flou directionnel ; la coupe se fait sur l'image du milieu. Toujours dans le même sens que le mouvement du plan suivant.

## Secousse (impact, bousculade)

Petits déplacements et rotations au hasard, forts pendant 6 à 10 images puis qui s'éteignent. Une secousse par impact sonore.

```bash
# Secousse entre 1 s et 1,4 s qui s'éteint. L'image est recadrée à 90 % pour cacher les bords.
ffmpeg -i in.mp4 -vf "crop=iw*0.9:ih*0.9:x='(iw-ow)/2+between(t,1,1.4)*(random(1)-0.5)*60*(1.4-t)/0.4':y='(ih-oh)/2+between(t,1,1.4)*(random(2)-0.5)*60*(1.4-t)/0.4',scale=720:540" -c:a copy secousse.mp4
```

## Couche « vidéo 2005 » (toujours, sur la vidéo finie)

Réduire l'image à 480 px de haut puis la remettre en grand, bruit fin, léger flou, couleurs un peu poussées, réencodage en qualité basse. Le script le fait :

```bash
bash scripts/couche-2005.sh ma-video.mp4
```

Ce qu'il lance (1080 = hauteur de sortie, 1920 pour une vidéo verticale) :

```bash
ffmpeg -i in.mp4 -vf "scale=-2:480,scale=-2:1080:flags=bilinear,noise=alls=12:allf=t,unsharp=5:5:-0.6,eq=saturation=1.08:contrast=1.05" -c:v libx264 -crf 30 -preset veryfast -c:a copy out-2005.mp4
```

Pour le look GoPro, si le rond sombre sur les bords est voulu et que l'IA ne l'a pas fait : ajoute `,vignette=PI/3.2` à la fin du filtre.
