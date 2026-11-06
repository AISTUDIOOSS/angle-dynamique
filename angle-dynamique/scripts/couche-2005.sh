#!/usr/bin/env bash
# Couche « vidéo 2005 » : image réduite puis agrandie, bruit, léger flou, réencodage bas de gamme.
# Usage : bash couche-2005.sh entree.mp4 [sortie.mp4]
set -euo pipefail

in="${1:?Donne la vidéo : bash couche-2005.sh entree.mp4}"
out="${2:-${in%.*}-2005.mp4}"
command -v ffmpeg >/dev/null || { echo "FFmpeg manque. Sur Mac : brew install ffmpeg" >&2; exit 1; }

height=$(ffprobe -v error -select_streams v:0 -show_entries stream=height -of csv=p=0 "$in")

ffmpeg -y -i "$in" \
  -vf "scale=-2:480,scale=-2:${height}:flags=bilinear,noise=alls=12:allf=t,unsharp=5:5:-0.6,eq=saturation=1.08:contrast=1.05" \
  -c:v libx264 -crf 30 -preset veryfast -pix_fmt yuv420p -c:a copy "$out"

echo "Fini : $out"
