#!/usr/bin/env bash
set -euo pipefail

# Launches the FREE native StarCraft client (1.18+ / Remastered engine)
# installed via Battle.net. No Wine, no CrossOver — fullscreen is native.
#
# Run ./scripts/install-starcraft-native.sh first if the game is not installed.

# Blizzard's free/Remastered client installs the playable app here by default.
APP_CANDIDATES=(
  "/Applications/StarCraft/StarCraft.app"
  "/Applications/StarCraft.app"
  "$HOME/Applications/StarCraft/StarCraft.app"
)

GAME_APP="${GAME_APP:-}"
if [[ -z "$GAME_APP" ]]; then
  for cand in "${APP_CANDIDATES[@]}"; do
    if [[ -d "$cand" ]]; then
      GAME_APP="$cand"
      break
    fi
  done
fi

if [[ -z "$GAME_APP" || ! -d "$GAME_APP" ]]; then
  echo "error: StarCraft.app not found in the usual locations." >&2
  echo "Checked:" >&2
  printf '  %s\n' "${APP_CANDIDATES[@]}" >&2
  echo "Install it first:  ./scripts/install-starcraft-native.sh" >&2
  echo "Or set GAME_APP=/path/to/StarCraft.app and re-run." >&2
  exit 1
fi

echo "Launching native StarCraft: $GAME_APP"
open "$GAME_APP"

cat <<'EOF'

Fullscreen: the native client renders fullscreen by default. If it opens
windowed, set Options -> Graphics -> Display Mode -> "Fullscreen", or use
the macOS green full-screen button / Control-Command-F.
EOF
