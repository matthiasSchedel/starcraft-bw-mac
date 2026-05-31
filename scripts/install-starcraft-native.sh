#!/usr/bin/env bash
set -euo pipefail

# Installs the FREE official StarCraft client (the modern 1.18+ / Remastered
# engine, free in SD mode) natively on macOS via Battle.net — no Wine, no
# CrossOver. This path renders fullscreen out of the box; the legacy 1.16.1
# CrossOver recipe lives in the sibling scripts.
#
# Cost: the classic StarCraft + Brood War in SD graphics is FREE. You do NOT
# need to buy anything to play Brood War fullscreen. "StarCraft: Remastered"
# (HD widescreen) is a paid in-client upgrade, and StarCraft II is a separate
# game — neither is required here.
#
# Blizzard ships StarCraft only through the Battle.net desktop app, and the
# download is gated behind a (free) Blizzard account login. That login is the
# one manual step this script cannot automate — it opens the installer and
# tells you exactly what to click.

# The Battle.net installer Blizzard ships (and the Homebrew cask) is an Intel
# binary, so Apple Silicon needs Rosetta 2. The game itself has a native
# Apple Silicon build that Battle.net pulls down after login.
if [[ "$(uname -m)" == "arm64" ]]; then
  if ! /usr/bin/pgrep -q oahd && ! /usr/bin/arch -x86_64 /usr/bin/true 2>/dev/null; then
    echo "Apple Silicon detected and Rosetta 2 is not installed."
    echo "The Battle.net installer is Intel-only and needs it. Install with:"
    echo "  softwareupdate --install-rosetta --agree-to-license"
    echo "Then re-run this script."
    exit 1
  fi
fi

BATTLENET_APP="/Applications/Battle.net.app"

if [[ ! -d "$BATTLENET_APP" ]]; then
  if ! command -v brew >/dev/null 2>&1; then
    echo "error: Homebrew not found. Install it from https://brew.sh first." >&2
    exit 1
  fi
  echo "Installing the Battle.net bootstrapper via Homebrew..."
  brew install --cask battle-net
fi

# The Homebrew cask stages an installer (Battle.net-Setup.app) that downloads
# and installs the real Battle.net.app on first run. Open whichever exists.
open_target=""
if [[ -d "$BATTLENET_APP" ]]; then
  open_target="$BATTLENET_APP"
else
  setup_app="$(/usr/bin/find "$(brew --prefix)/Caskroom/battle-net" -maxdepth 3 -iname 'Battle.net-Setup.app' 2>/dev/null | head -1 || true)"
  if [[ -n "$setup_app" ]]; then
    open_target="$setup_app"
  fi
fi

if [[ -z "$open_target" ]]; then
  echo "error: could not find Battle.net.app or Battle.net-Setup.app." >&2
  echo "Try: brew reinstall --cask battle-net" >&2
  exit 1
fi

echo "Opening: $open_target"
open "$open_target"

cat <<'EOF'

Next steps (manual — Blizzard requires an account login to download the game):

  1. Let the installer finish setting up Battle.net, then log in (or create a
     free Blizzard account).
  2. Top tab "Games" -> select "StarCraft" -> click "Install".
       The classic StarCraft + Brood War (SD graphics) is FREE. You do NOT
       need to buy Remastered or StarCraft II to play fullscreen.
  3. Wait for the download to finish (a few GB).
  4. Launch the game once from Battle.net so it finalizes the install.

Then run:  ./scripts/launch-starcraft-native.sh

Fullscreen: the native client renders fullscreen by default. If it opens
windowed, set it in-game under Options -> Graphics -> Display Mode ->
"Fullscreen" (or "Fullscreen (Windowed)"), or press the macOS green
full-screen button / Control-Command-F.
EOF
