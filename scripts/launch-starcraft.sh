#!/usr/bin/env bash
set -euo pipefail

BOTTLE_NAME="${BOTTLE_NAME:-starcraft-bw}"
CX_ROOT="${CX_ROOT:-/Applications/CrossOver.app/Contents/SharedSupport/CrossOver}"
BOTTLES_DIR="${BOTTLES_DIR:-$HOME/Library/Application Support/CrossOver/Bottles}"
GAME_DIR="${GAME_DIR:-$BOTTLES_DIR/$BOTTLE_NAME/drive_c/Games/StarCraft/Starcraft}"
EXE="${EXE:-StarCraft.exe}"

if [[ ! -x "$CX_ROOT/bin/wine" ]]; then
  echo "Missing CrossOver wine at: $CX_ROOT/bin/wine" >&2
  echo "Install CrossOver or set CX_ROOT to its SharedSupport/CrossOver directory." >&2
  exit 1
fi

if [[ ! -d "$BOTTLES_DIR/$BOTTLE_NAME" ]]; then
  echo "Missing CrossOver bottle: $BOTTLES_DIR/$BOTTLE_NAME" >&2
  echo "Run ./scripts/create-crossover-bottle.sh first." >&2
  exit 1
fi

if [[ ! -f "$GAME_DIR/$EXE" ]]; then
  echo "Missing game executable: $GAME_DIR/$EXE" >&2
  echo "Extract your StarCraft 1.16.1 + Brood War files or set GAME_DIR." >&2
  exit 1
fi

cd "$GAME_DIR"
exec "$CX_ROOT/bin/wine" --bottle="$BOTTLE_NAME" --workdir "$GAME_DIR" --cx-app="$EXE"
