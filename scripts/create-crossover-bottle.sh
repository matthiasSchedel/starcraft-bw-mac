#!/usr/bin/env bash
set -euo pipefail

BOTTLE_NAME="${BOTTLE_NAME:-starcraft-bw}"
CX_ROOT="${CX_ROOT:-/Applications/CrossOver.app/Contents/SharedSupport/CrossOver}"
BOTTLES_DIR="${BOTTLES_DIR:-$HOME/Library/Application Support/CrossOver/Bottles}"
BOTTLE_DIR="$BOTTLES_DIR/$BOTTLE_NAME"
CONF="$BOTTLE_DIR/cxbottle.conf"

if [[ ! -x "$CX_ROOT/bin/cxbottle" ]]; then
  echo "Missing cxbottle at: $CX_ROOT/bin/cxbottle" >&2
  echo "Install CrossOver or set CX_ROOT to its SharedSupport/CrossOver directory." >&2
  exit 1
fi

if [[ ! -d "$BOTTLE_DIR" ]]; then
  "$CX_ROOT/bin/cxbottle" \
    --bottle "$BOTTLE_NAME" \
    --create \
    --description "StarCraft Brood War 1.16.1" \
    --template winxp
fi

if [[ ! -f "$CONF" ]]; then
  echo "Bottle config not found after create: $CONF" >&2
  exit 1
fi

if grep -q '^"AntiVirusScan"' "$CONF"; then
  perl -0pi -e 's/^"AntiVirusScan"\s*=\s*".*"/"AntiVirusScan" = "never"/m' "$CONF"
elif grep -q '^\[CrossOver\]' "$CONF"; then
  perl -0pi -e 's/(\[CrossOver\]\n)/$1"AntiVirusScan" = "never"\n/' "$CONF"
else
  printf '\n[CrossOver]\n"AntiVirusScan" = "never"\n' >> "$CONF"
fi

INSTALL_PARENT="$BOTTLE_DIR/drive_c/Games/StarCraft"
mkdir -p "$INSTALL_PARENT"

cat <<EOF
Bottle ready: $BOTTLE_NAME
Config updated: "AntiVirusScan" = "never"

Extract StarCraft 1.16.1 + Brood War so StarCraft.exe ends up here:
$INSTALL_PARENT/Starcraft/StarCraft.exe

Then run:
./scripts/launch-starcraft.sh
EOF
