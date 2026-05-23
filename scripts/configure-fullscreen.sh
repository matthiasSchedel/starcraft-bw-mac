#!/usr/bin/env bash
set -euo pipefail

BOTTLE_NAME="${BOTTLE_NAME:-starcraft-bw}"
CX_ROOT="${CX_ROOT:-/Applications/CrossOver.app/Contents/SharedSupport/CrossOver}"
BOTTLES_DIR="${BOTTLES_DIR:-$HOME/Library/Application Support/CrossOver/Bottles}"
BOTTLE_DIR="$BOTTLES_DIR/$BOTTLE_NAME"
CONF="$BOTTLE_DIR/cxbottle.conf"

detect_display_size() {
  system_profiler SPDisplaysDataType 2>/dev/null |
    awk '/Resolution:/{print $2, $4; exit}'
}

DISPLAY_SIZE="$(detect_display_size || true)"
read -r DETECTED_WIDTH DETECTED_HEIGHT <<< "$DISPLAY_SIZE"
WIDTH="${FULLSCREEN_WIDTH:-${DETECTED_WIDTH:-2560}}"
HEIGHT="${FULLSCREEN_HEIGHT:-${DETECTED_HEIGHT:-1600}}"
DESKTOP_SIZE="${WIDTH}x${HEIGHT}"

if [[ ! -x "$CX_ROOT/bin/wine" ]]; then
  echo "Missing CrossOver wine at: $CX_ROOT/bin/wine" >&2
  echo "Install CrossOver or set CX_ROOT to its SharedSupport/CrossOver directory." >&2
  exit 1
fi

if [[ ! -d "$BOTTLE_DIR" ]]; then
  echo "Missing CrossOver bottle: $BOTTLE_DIR" >&2
  echo "Run scripts/create-crossover-bottle.sh first." >&2
  exit 1
fi

if [[ -f "$CONF" ]]; then
  if grep -q '^"WineFullScreen"' "$CONF"; then
    perl -0pi -e 's/^"WineFullScreen"\s*=\s*".*"/"WineFullScreen" = "true"/m' "$CONF"
  elif grep -q '^\[CrossOver\]' "$CONF"; then
    perl -0pi -e 's/(\[CrossOver\]\n)/$1"WineFullScreen" = "true"\n/' "$CONF"
  else
    printf '\n[CrossOver]\n"WineFullScreen" = "true"\n' >> "$CONF"
  fi
fi

"$CX_ROOT/bin/wine" --bottle="$BOTTLE_NAME" reg add \
  'HKCU\Software\Wine\Explorer\Desktops' \
  /v Default /d "$DESKTOP_SIZE" /f

echo "Configured Wine virtual desktop: Default=$DESKTOP_SIZE"
echo "Launch inside it with:"
echo "  $CX_ROOT/bin/wine --bottle=$BOTTLE_NAME explorer /desktop=Default,$DESKTOP_SIZE StarCraft.exe"
