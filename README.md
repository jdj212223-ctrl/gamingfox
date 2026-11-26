# GamingFox 🦊🎮

**A web browser for gamers, built from Mozilla's Firefox source code** — our own name, our own fox,
tuned for gaming PCs. It's the browser in [Hollow OS](https://github.com/jdj212223-ctrl/hollow-os).

- **Video on the graphics card** (VA-API): YouTube and Twitch use the GPU, not the CPU.
- **Easy on RAM:** fewer background processes, and old tabs unload when memory gets low.
- **Kind to your SSD:** the web cache lives in memory, and open tabs are saved once a minute instead of every 15 s.
- **No ads, no tracking:** uBlock Origin comes installed; no telemetry, no studies, no Pocket, no sponsored tiles.
- **🎮 Game Mode:** while a game runs (or when you press the Game Mode button in the toolbar) videos and music
  pause and background tabs are unloaded, so the game gets the CPU and RAM. It turns itself on with Feral GameMode
  (`gamemoderun`, built into Hollow OS) and off when the game ends.
- **Dark theme** and a gaming start page.

## Download

Get it from [Releases](https://github.com/jdj212223-ctrl/gamingfox/releases):

| Computer | File | How |
|---|---|---|
| Hollow OS / Fedora | `gamingfox-*.x86_64.rpm` | `sudo dnf install ./gamingfox-*.x86_64.rpm` (Hollow OS has it built in) |
| Ubuntu / Debian / Mint | `gamingfox_*_amd64.deb` | double-click, or `sudo apt install ./gamingfox_*_amd64.deb` |
| Any Linux (x86_64) | `gamingfox-*.linux-x86_64.tar.xz` | unpack and run `gamingfox/gamingfox` |
| Windows 10/11 (64-bit) | `GamingFox-*-Setup.exe` (or the `.zip`) | run it; if Windows warns, **More info → Run anyway** (not signed) |
| Mac with Apple Silicon (M1+) | `GamingFox-*-mac-arm64.dmg` | drag to Applications, then **right-click → Open** the first time (not signed by Apple); on macOS 15+: **System Settings → Privacy & Security → Open Anyway** |

## How it's built

Everything is built by GitHub Actions ([`.github/workflows/build.yml`](.github/workflows/build.yml)), not on anyone's computer:

1. Downloads the newest Firefox source code from Mozilla and checks its checksum.
2. Adds GamingFox's branding ([`branding/`](branding)) and build settings ([`mozconfig`](mozconfig)).
3. Compiles for Linux, Windows and Mac at the same time, all on Linux machines (Windows and Mac are "cross-compiled").
   A compiler cache makes later builds much faster. If GitHub's 6-hour limit is reached, a second job carries on.
4. Adds our settings ([`settings/`](settings)): `gamingfox.cfg` (gaming tweaks + Game Mode), `policies.json`
   (uBlock Origin, no telemetry), and the start page.
5. Makes the `.rpm`, `.deb`, Windows installer and Mac `.dmg`, installs each on a real Fedora, Ubuntu, Windows and Mac
   machine, takes a screenshot of the start page to prove it starts, and publishes them all in one release.

Every Wednesday it checks for a new Firefox release and rebuilds, so security fixes arrive quickly.

## Licence and trademarks

GamingFox is based on Mozilla Firefox source code, under the [Mozilla Public License 2.0](https://www.mozilla.org/MPL/2.0/).
It is not made or endorsed by Mozilla. "Firefox" and the Firefox logos are trademarks of the Mozilla Foundation and are
not used for GamingFox's name or icons; the GamingFox fox is our own artwork.
