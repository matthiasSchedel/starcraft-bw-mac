#!/bin/zsh
set -euo pipefail
APPDIR="$(cd "$(dirname "$0")/.." && pwd)"
LOG="$HOME/Library/Logs/starcraft-launcher.log"
exec >> "$LOG" 2>&1
echo "[$(date)] Launching StarCraft from $APPDIR"

CX=""
for candidate in "/tmp/starcraft-crossover-runtime/CrossOver.app" "/Applications/CrossOver.app"; do
  if [ -x "$candidate/Contents/SharedSupport/CrossOver/bin/wine" ]; then
    CX="$candidate/Contents/SharedSupport/CrossOver/bin"
    break
  fi
done
if [ -z "$CX" ]; then
  osascript -e 'display alert "CrossOver not found" message "Install CrossOver from https://www.codeweavers.com/crossover/"'
  exit 1
fi

BOTTLE="$HOME/Library/Application Support/CrossOver/Bottles/starcraft-retry"
if [ ! -d "$BOTTLE" ]; then
  osascript -e 'display alert "StarCraft bottle missing" message "Bottle starcraft-retry not found. See https://github.com/matthiasSchedel/starcraft-bw-mac for setup."'
  exit 1
fi

EXE="$BOTTLE/drive_c/Games/StarCraft/Starcraft/StarCraft.exe"
if [ ! -f "$EXE" ]; then
  osascript -e "display alert \"StarCraft not installed\" message \"Game files missing at $EXE.\""
  exit 1
fi

cd "$(dirname "$EXE")"
if [ -n "" ]; then
  export WINEDLLOVERRIDES=""
fi
exec "$CX/wine" --bottle=starcraft-retry --workdir "C:\Games\StarCraft\Starcraft" --cx-app="StarCraft.exe"
