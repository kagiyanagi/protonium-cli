#!/usr/bin/env bash
set -Eeuo pipefail
IFS=$'\n\t'

BIN="${HOME}/.local/bin/protonium-cli"
SYSTEMD_USER_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/systemd/user"
CONFIG_DIR="${PROTONIUM_CONFIG_DIR:-${XDG_CONFIG_HOME:-$HOME/.config}/protonium-cli}"
STATE_DIR="${PROTONIUM_STATE_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/protonium-cli}"
VPN_DIR="${PROTONIUM_VPN_DIR:-$HOME/.vpns}"

YES=0
KEEP_NM=0
KEEP_CONFIG=0
PURGE_VPNS=0

warn() {
    printf 'warning: %s\n' "$*" >&2
}

usage() {
    cat <<'USAGE'
Usage:
  ./uninstall.sh [--yes] [--keep-nm] [--keep-config] [--purge-vpns]

Default behavior:
  - disables and removes Protonium user systemd units
  - disconnects active Protonium-managed VPNs
  - removes imported Protonium NetworkManager profiles
  - removes ~/.local/bin/protonium-cli
  - removes Protonium credentials and state
  - preserves downloaded ~/.vpns/*.ovpn files

Options:
  --yes          Do not prompt for confirmation.
  --keep-nm      Keep imported NetworkManager VPN profiles.
  --keep-config  Keep Protonium credentials and state files.
  --purge-vpns   Delete ~/.vpns as well.
USAGE
}

while (($# > 0)); do
    case "$1" in
        --yes|-y) YES=1 ;;
        --keep-nm) KEEP_NM=1 ;;
        --keep-config) KEEP_CONFIG=1 ;;
        --purge-vpns) PURGE_VPNS=1 ;;
        --help|-h) usage; exit 0 ;;
        *) usage >&2; exit 1 ;;
    esac
    shift
done

if ((YES == 0)); then
    printf 'This will uninstall protonium-cli for the current user.\n'
    if ((PURGE_VPNS == 1)); then
        printf 'It will also delete %s.\n' "$VPN_DIR"
    else
        printf 'Downloaded VPN configs in %s will be preserved.\n' "$VPN_DIR"
    fi
    printf 'Continue? [y/N] '
    IFS= read -r answer
    case "$answer" in
        y|Y|yes|YES) ;;
        *) printf 'Aborted.\n'; exit 0 ;;
    esac
fi

if command -v systemctl >/dev/null 2>&1 && systemctl --user show-environment >/dev/null 2>&1; then
    systemctl --user disable --now protonium-rotate.timer protonium-autoconnect.service >/dev/null 2>&1 || true
    systemctl --user stop protonium-rotate.service >/dev/null 2>&1 || true
fi

if [[ -x "$BIN" ]]; then
    "$BIN" stop >/dev/null 2>&1 || true
    if ((KEEP_NM == 0)); then
        "$BIN" uninstall-connections || true
    fi
fi

rm -f "$SYSTEMD_USER_DIR/protonium-autoconnect.service"
rm -f "$SYSTEMD_USER_DIR/protonium-rotate.service"
rm -f "$SYSTEMD_USER_DIR/protonium-rotate.timer"

if command -v systemctl >/dev/null 2>&1 && systemctl --user show-environment >/dev/null 2>&1; then
    systemctl --user daemon-reload >/dev/null 2>&1 || true
fi

rm -f "$BIN"

if ((KEEP_CONFIG == 0)); then
    rm -rf "$CONFIG_DIR" "$STATE_DIR"
fi

if ((PURGE_VPNS == 1)); then
    rm -rf "$VPN_DIR"
fi

printf 'Uninstalled protonium-cli.\n'

if ((PURGE_VPNS == 0)); then
    printf 'Preserved VPN configs in %s.\n' "$VPN_DIR"
fi
