#!/usr/bin/env bash
set -euo pipefail

# Installs the FREE official StarCraft client (the modern 1.18+ / Remastered
# engine, free in SD mode) natively on macOS via Battle.net — no Wine, no
# CrossOver. This path renders fullscreen out of the box; the legacy 1.16.1
# CrossOver recipe lives in the sibling scripts.
#
# Blizzard ships StarCraft only through the Battle.net desktop app, and the
# download is gated behind a (free) Blizzard account login. That login is the
# one manual step this script cannot automate — it opens Battle.net and tells
# you exactly what to click.

BATTLENET_APP="/Applications/Battle.net.app"

if [[ -d "$BATTLENET_APP" ]]; then
  echo "Battle.net already installed: $BATTLENET_APP"
else
  if ! command -v brew >/dev/null 2>&1; then
    echo "error: Homebrew not found. Install it from https://brew.sh first." >&2
    exit 1
  fi
  echo "Installing Battle.net via Homebrew..."
  brew install --cask battle-net
fi

echo "Opening Battle.net..."
open -a "Battle.net"

cat <<'EOF'

Next steps (manual — Blizzard requires an account login to download the game):

  1. In Battle.net, log in (or create a free Blizzard account).
  2. Top tab "Games" -> select "StarCraft" -> click "Install".
       The classic StarCraft + Brood War (Remastered engine, SD graphics)
       is FREE. You do not need to buy Remastered to play fullscreen.
  3. Wait for the download to finish (a few GB).
  4. Launch the game once from Battle.net so it finalizes the install.

Then run:  ./scripts/launch-starcraft-native.sh

Fullscreen: the native client renders fullscreen by default. If it opens
windowed, set it in-game under Options -> Graphics -> Display Mode ->
"Fullscreen" (or "Fullscreen (Windowed)"), or press the macOS green
full-screen button / Control-Command-F.
EOF
