#!/usr/bin/env bash
# Makes the .deb (Debian, Ubuntu, Mint, Pop!_OS...) from the finished Linux .tar.xz.
# Usage: packaging/build-deb.sh <gamingfox-VERSION.linux-x86_64.tar.xz> <version> <build-number> <out-dir>
set -euo pipefail
GF="$(cd "$(dirname "$0")/.." && pwd)"
T="$1"; V="$2"; N="$3"; OUT="$4"
R=$(mktemp -d)/gamingfox
mkdir -p "$R/DEBIAN" "$R/usr/lib/gamingfox" "$R/usr/bin"
tar -xJf "$T" -C "$R/usr/lib/gamingfox" --strip-components=1
ln -s /usr/lib/gamingfox/gamingfox "$R/usr/bin/gamingfox"
install -Dm644 "$GF/packaging/gamingfox.desktop" "$R/usr/share/applications/gamingfox.desktop"
install -Dm644 "$GF/branding/gamingfox.svg" "$R/usr/share/icons/hicolor/scalable/apps/gamingfox.svg"
for s in 16 32 48 64 128; do
  install -Dm644 "$R/usr/lib/gamingfox/browser/chrome/icons/default/default$s.png" \
    "$R/usr/share/icons/hicolor/${s}x${s}/apps/gamingfox.png"
done
size=$(du -sk "$R/usr" | cut -f1)
cat > "$R/DEBIAN/control" <<CTRL
Package: gamingfox
Version: $V-$N
Architecture: amd64
Maintainer: Hollow <https://github.com/jdj212223-ctrl/gamingfox/issues>
Installed-Size: $size
Depends: libgtk-3-0t64 | libgtk-3-0, libasound2t64 | libasound2, libx11-xcb1, libdbus-1-3, fontconfig
Recommends: libavcodec61 | libavcodec60 | libavcodec59 | libavcodec-extra, gamemode
Provides: www-browser, gnome-www-browser
Section: web
Priority: optional
Homepage: https://github.com/jdj212223-ctrl/gamingfox
Description: GamingFox: a web browser for gamers, built on the Firefox engine
 Video on the graphics card (VA-API), low RAM use, cache in memory to spare the
 SSD, uBlock Origin, no telemetry, no sponsored content, and a Game Mode that
 pauses videos and unloads background tabs while a game runs.
CTRL
cat > "$R/DEBIAN/postinst" <<'POST'
#!/bin/sh
set -e
update-alternatives --install /usr/bin/x-www-browser x-www-browser /usr/bin/gamingfox 70 || true
update-alternatives --install /usr/bin/gnome-www-browser gnome-www-browser /usr/bin/gamingfox 70 || true
command -v update-desktop-database >/dev/null && update-desktop-database -q /usr/share/applications || true
command -v gtk-update-icon-cache >/dev/null && gtk-update-icon-cache -q /usr/share/icons/hicolor || true
POST
cat > "$R/DEBIAN/prerm" <<'PRE'
#!/bin/sh
set -e
if [ "$1" = remove ]; then
  update-alternatives --remove x-www-browser /usr/bin/gamingfox || true
  update-alternatives --remove gnome-www-browser /usr/bin/gamingfox || true
fi
PRE
chmod 755 "$R/DEBIAN/postinst" "$R/DEBIAN/prerm"
mkdir -p "$OUT"
dpkg-deb --root-owner-group -Zxz --build "$R" "$OUT/gamingfox_${V}-${N}_amd64.deb"
