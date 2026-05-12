#!/bin/sh
set -e
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/branding"
mkdir -p "$ROOT/config/extensions"
rm -f "$ROOT/config/extensions/guacamole-branding-local.jar"
zip -qr "$ROOT/config/extensions/guacamole-branding-local.jar" .
echo "Wrote $ROOT/config/extensions/guacamole-branding-local.jar — перезапустите guacamole: docker compose restart guacamole"
