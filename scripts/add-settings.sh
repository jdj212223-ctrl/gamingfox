#!/usr/bin/env bash
# Adds GamingFox's settings, policies and start page into the finished browser folder.
# Usage: scripts/add-settings.sh /path/to/gamingfox   (the folder that holds the "gamingfox" program)
set -euo pipefail
GF="$(cd "$(dirname "$0")/.." && pwd)"
D="$1"
install -Dm644 "$GF/settings/policies.json" "$D/distribution/policies.json"
install -Dm644 "$GF/settings/autoconfig.js"  "$D/defaults/pref/autoconfig.js"
install -Dm644 "$GF/settings/gamingfox.cfg"  "$D/gamingfox.cfg"
install -Dm644 "$GF/settings/start.html"     "$D/start.html"
install -Dm644 "$GF/branding/gamingfox.svg"  "$D/gamingfox.svg"
