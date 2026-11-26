#!/usr/bin/env bash
# Compiles GamingFox inside GitHub Actions. Usage: TARGET=linux|windows|mac scripts/ci-compile.sh <firefox-version> <minutes-allowed>
# If time runs out it stops cleanly and says done=false; the next job carries on (the compiled pieces are
# kept in the sccache folder, so the second try only compiles what is left).
set -euo pipefail
V="$1"; BUDGET_MIN="$2"
GF="$(cd "$(dirname "$0")/.." && pwd)"
SRC=/gf/src
out() { echo "$1" >> "${GITHUB_OUTPUT:-/dev/null}"; }

# 1. Firefox's source code, straight from Mozilla, checked against Mozilla's checksum list.
mkdir -p /gf/dl
cd /gf/dl
tarball="firefox-$V.source.tar.xz"
curl -fL --retry 5 -o "$tarball" "https://archive.mozilla.org/pub/firefox/releases/$V/source/$tarball"
curl -fsSL --retry 5 "https://archive.mozilla.org/pub/firefox/releases/$V/SHA256SUMS" \
  | grep " source/$tarball\$" | sed "s# source/# #" | sha256sum -c -
rm -rf "$SRC" && mkdir -p "$SRC"
tar -xJf "$tarball" -C "$SRC" --strip-components=1
rm -f "$tarball"

# 2. Our name, icons and build settings.
"$GF/scripts/apply-branding.sh" "$SRC"

# 3. The compilers and tools Mozilla's build needs (mach fetches them).
cd "$SRC"
export MOZBUILD_STATE_PATH="$HOME/.mozbuild"
./mach --no-interactive bootstrap --application-choice=browser

# 4. Compile, within the time we have.
sccache --start-server || true
set +e
timeout --signal=INT --kill-after=3m "${BUDGET_MIN}m" ./mach build
rc=$?
set -e
sccache --show-stats || true
if [ $rc -eq 124 ] || [ $rc -eq 130 ] || [ $rc -eq 137 ]; then
  echo "::warning::Ran out of time this round; the next job continues from the saved pieces."
  out "done=false"
  exit 0
fi
[ $rc -eq 0 ] || exit $rc

# 5. Pack it up: the browser + our settings, policies and start page.
./mach package
TARGET="${TARGET:-linux}"
rm -rf /gf/pkg && mkdir -p /gf/pkg "$GITHUB_WORKSPACE/out"
case "$TARGET" in
  linux)
    tar -xf "$(ls obj-gamingfox/dist/gamingfox-*.tar.* | head -1)" -C /gf/pkg
    "$GF/scripts/add-settings.sh" /gf/pkg/gamingfox
    tar -C /gf/pkg -cJf "$GITHUB_WORKSPACE/out/gamingfox-$V.linux-x86_64.tar.xz" gamingfox ;;
  windows)
    (cd /gf/pkg && unzip -q "$SRC/$(ls obj-gamingfox/dist/gamingfox-*.zip | head -1)")
    "$GF/scripts/add-settings.sh" /gf/pkg/gamingfox
    for s in 16 24 32 48 64 128 256; do rsvg-convert -w $s -h $s "$GF/branding/gamingfox.svg" -o /gf/ico-$s.png; done
    convert /gf/ico-{16,24,32,48,64,128,256}.png /gf/pkg/gamingfox/gamingfox.ico   # for the installer
    (cd /gf/pkg && zip -qr9 "$GITHUB_WORKSPACE/out/gamingfox-$V.windows-x86_64.zip" gamingfox) ;;
  mac)
    tar -xf "$(ls obj-gamingfox/dist/gamingfox-*.tar | head -1)" -C /gf/pkg
    app=$(find /gf/pkg -maxdepth 3 -name '*.app' -type d | head -1)
    "$GF/scripts/add-settings.sh" "$app/Contents/Resources"
    tar -C "$(dirname "$app")" -cJf "$GITHUB_WORKSPACE/out/gamingfox-$V.mac-arm64.app.tar.xz" "$(basename "$app")" ;;
esac
ls -lh "$GITHUB_WORKSPACE/out"
out "done=true"
