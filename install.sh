#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

APP_NAME="protonium-cli"
ROOT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
SOURCE_BIN="$ROOT_DIR/src/protonium-cli"
TARGET_BIN_DIR="${HOME}/.local/bin"
TARGET_BIN="$TARGET_BIN_DIR/protonium-cli"

die() {
    printf 'error: %s\n' "$*" >&2
    exit 1
}

warn() {
    printf 'warning: %s\n' "$*" >&2
}

[[ -f "$SOURCE_BIN" ]] || die "missing source binary: $SOURCE_BIN"

install -d -m 755 "$TARGET_BIN_DIR"
install -m 755 "$SOURCE_BIN" "$TARGET_BIN"

if "$TARGET_BIN" systemd-install >/dev/null; then
    printf 'Installed user systemd unit files.\n'
else
    warn "could not install systemd user units"
fi

printf 'Installed %s to %s\n' "$APP_NAME" "$TARGET_BIN"

case ":${PATH}:" in
    *":$TARGET_BIN_DIR:"*) ;;
    *) warn "$TARGET_BIN_DIR is not in PATH" ;;
esac

cat <<NEXT

Next steps:
  protonium-cli setup
  protonium-cli list
  protonium-cli auto
  protonium-cli enable

Put Proton VPN .ovpn files in ~/.vpns before enabling rotation.
NEXT
