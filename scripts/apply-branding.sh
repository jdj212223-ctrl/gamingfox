#!/usr/bin/env bash
# Puts GamingFox's name, icons and settings into an unpacked Firefox source folder.
# Usage: scripts/apply-branding.sh /path/to/firefox-source
set -euo pipefail
GF="$(cd "$(dirname "$0")/.." && pwd)"
SRC="$1"
B="$SRC/browser/branding/gamingfox"

# Start from Firefox's "unofficial" branding (it has every file the build expects, and no Firefox logo),
# then lay our own files on top.
rm -rf "$B"
cp -r "$SRC/browser/branding/unofficial" "$B"
cp -r "$GF/branding/configure.sh" "$GF/branding/content" "$GF/branding/locales" "$GF/branding/pref" "$B/"

# Every picture in the branding folder becomes our fox, drawn at that picture's size
# (centred on a see-through background when the picture isn't square).
find "$B" -name '*.png' | while read -r png; do
  read -r w h < <(python3 -c 'import struct,sys; d=open(sys.argv[1],"rb").read(24); print(*struct.unpack(">II",d[16:24]))' "$png")
  s=$(( w < h ? w : h ))
  rsvg-convert -w "$s" -h "$s" --page-width "$w" --page-height "$h" \
    --left $(( (w - s) / 2 )) --top $(( (h - s) / 2 )) "$GF/branding/gamingfox.svg" -o "$png"
done

cp "$GF/mozconfig" "$SRC/mozconfig"
echo "GamingFox branding applied to $B"
