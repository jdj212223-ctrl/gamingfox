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

# Windows (.ico) and Mac (.icns) icons: our fox too.
tmp=$(mktemp -d)
for s in 16 24 32 48 64 128 256 512 1024; do rsvg-convert -w $s -h $s "$GF/branding/gamingfox.svg" -o "$tmp/$s.png"; done
if command -v convert >/dev/null; then
  find "$B" -name '*.ico' | while read -r ico; do
    convert "$tmp"/{16,24,32,48,64,128,256}.png "$ico"
  done
fi
if command -v png2icns >/dev/null; then
  find "$B" -name '*.icns' | while read -r icns; do
    png2icns "$icns" "$tmp"/{16,32,48,128,256,512}.png >/dev/null
  done
fi
rm -rf "$tmp"

# Settings only Firefox's own browser config may set: our vendor name and our own profile folder (~/.gamingfox).
grep -q 'imply_option("MOZ_APP_VENDOR", "Mozilla")' "$SRC/browser/moz.configure"
sed -i 's/imply_option("MOZ_APP_VENDOR", "Mozilla")/imply_option("MOZ_APP_VENDOR", "Hollow")/' "$SRC/browser/moz.configure"
grep -q 'MOZ_APP_PROFILE' "$SRC/browser/moz.configure" || echo 'imply_option("MOZ_APP_PROFILE", "gamingfox")' >> "$SRC/browser/moz.configure"

cp "$GF/mozconfig" "$SRC/mozconfig"
# Which computer it's for: linux (default), windows or mac (both built on Linux, "cross-compiled").
case "${TARGET:-linux}" in
  windows) printf '%s\n' 'ac_add_options --target=x86_64-pc-windows-msvc' \
                         'ac_add_options --disable-debug-symbols   # lighter on memory' 'mk_add_options MOZ_PARALLEL_BUILD=3' >> "$SRC/mozconfig" ;;
  mac)     printf '%s\n' 'ac_add_options --target=aarch64-apple-darwin' \
                         'ac_add_options MOZ_PKG_FORMAT=TAR   # the .dmg is made on a real Mac afterwards' >> "$SRC/mozconfig" ;;
esac
echo "GamingFox branding applied to $B"
