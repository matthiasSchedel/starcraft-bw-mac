#!/usr/bin/env bash
set -euo pipefail

APP_NAME="StarCraft"
SLUG="starcraft"
EXE_PATH="${EXE_PATH:-$HOME/Library/Application Support/CrossOver/Bottles/starcraft-retry/drive_c/Games/StarCraft/Starcraft/StarCraft.exe}"

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
APP_DIR="${APP_DIR:-$HOME/Applications/$APP_NAME.app}"
ICON_WORK="${TMPDIR:-/tmp}/$SLUG-icon-work"

mkdir -p "$APP_DIR/Contents/MacOS" "$APP_DIR/Contents/Resources"
cp "$ROOT/app/Info.plist" "$APP_DIR/Contents/Info.plist"
install -m 0755 "$ROOT/app/launcher.sh" "$APP_DIR/Contents/MacOS/launcher"

rm -rf "$ICON_WORK"
mkdir -p "$ICON_WORK"
if [[ -f "$EXE_PATH" ]] && command -v wrestool >/dev/null 2>&1 && command -v icotool >/dev/null 2>&1; then
  if wrestool -x -t14 "$EXE_PATH" > "$ICON_WORK/icon.ico" 2>/dev/null && [[ -s "$ICON_WORK/icon.ico" ]]; then
    if icotool -x -o "$ICON_WORK" "$ICON_WORK/icon.ico" >/dev/null 2>&1; then
      best_png="$(find "$ICON_WORK" -type f -name '*.png' -print0 | xargs -0 ls -S 2>/dev/null | head -1 || true)"
      if [[ -n "${best_png:-}" ]]; then
        iconset="$ICON_WORK/icon.iconset"
        mkdir -p "$iconset"
        for size in 16 32 64 128 256 512; do
          sips -z "$size" "$size" "$best_png" --out "$iconset/icon_${size}x${size}.png" >/dev/null
          double=$((size * 2))
          if [[ "$double" -le 1024 ]]; then
            sips -z "$double" "$double" "$best_png" --out "$iconset/icon_${size}x${size}@2x.png" >/dev/null
          fi
        done
        iconutil -c icns "$iconset" -o "$APP_DIR/Contents/Resources/icon.icns"
      fi
    fi
  fi
fi

codesign --force --deep -s - "$APP_DIR"
echo "built $APP_DIR"
