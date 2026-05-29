# protonium-cli

Small Bash CLI for managing Proton VPN OpenVPN configs with NetworkManager.

`protonium-cli` is for users who manually download Proton VPN free-tier
`.ovpn` files and keep them in: `~/.vpns`

It imports those configs into NetworkManager, stores the VPN password as a
NetworkManager secret, connects without `nmcli --ask`, and can rotate servers
every 30 minutes with a user systemd timer.

> This project is not affiliated with Proton AG.

---
## Flow

```text
~/.vpns/*.ovpn
      |
      v
protonium-cli
      |
      v
NetworkManager profile + VPN secret
      |
      v
nmcli connection up
      |
      v
systemd user timer rotates every 30 min
```

---
## Features

- User-local install.
- No custom daemon.
- Uses Bash, `nmcli`, NetworkManager, and user systemd.
- Global auto-rotation.
- Country-only auto-rotation.
- Manual country or server lock.
- Manual mode pauses rotation until auto mode is enabled again.
- Startup reconnect support.
- Safe uninstall script.

---
## Dependencies

Required:

```text
bash
coreutils
findutils
util-linux
NetworkManager
nmcli
NetworkManager OpenVPN plugin
systemd user services
```

Note: package names may differ by distro:

```text
Arch:          networkmanager networkmanager-openvpn openvpn
Debian/Ubuntu: network-manager network-manager-openvpn openvpn
Fedora:        NetworkManager NetworkManager-openvpn openvpn
```

---
## Install

```bash
./install.sh
```

Installed files:

```text
~/.local/bin/protonium-cli
~/.config/systemd/user/protonium-autoconnect.service
~/.config/systemd/user/protonium-rotate.service
~/.config/systemd/user/protonium-rotate.timer
```

Make sure `~/.local/bin` is in `PATH`.

----
## Setup

Put Proton VPN configs in `~/.vpns`.

Expected names:

```text
ca-free-33.protonvpn.udp.ovpn
nl-free-9.protonvpn.udp.ovpn
```

Then run:

```bash
protonium-cli setup
```

Credentials are saved with `0600` permissions in:

```text
~/.config/protonium-cli
```

---
## Quick Use

```bash
protonium-cli list
protonium-cli auto
```

Rotate only one country:

```bash
protonium-cli auto NL
```

Lock one country:

```bash
protonium-cli manual CA
```

Lock one server:

```bash
protonium-cli manual ca-free-33
```

Enable startup reconnect and timer:

```bash
protonium-cli enable
```

Stop the VPN:

```bash
protonium-cli stop
```

Disable automation:

```bash
protonium-cli disable
```

---
## Commands

```text
setup                 Save credentials and import profiles.
status                Show connection, mode, pool, and systemd state.
list                  List configs found in ~/.vpns.
sync                  Import all configs and refresh credentials.
auto                  Rotate across all configs.
auto <COUNTRY_CODE>   Rotate only inside one country.
country <CODE>        Alias for auto <CODE>.
manual <CODE>         Pick one server from a country and pause rotation.
manual <SERVER>       Lock to one exact server and pause rotation.
stop                  Disconnect the active Protonium VPN.
enable                Enable startup reconnect and rotation.
disable               Disable startup reconnect and rotation.
```

---
## Modes

```text
auto
    Use every config in ~/.vpns.

auto NL
    Use only NL configs.

manual CA
    Choose one CA server and stay there.

manual ca-free-33
    Lock to ca-free-33 and stay there.
```

Manual mode always pauses rotation. Run `protonium-cli auto` to rotate again.

---
## Uninstall

```bash
./uninstall.sh
```

Default uninstall:

- disables user systemd units
- disconnects active Protonium VPNs
- removes imported Protonium NetworkManager profiles
- removes `~/.local/bin/protonium-cli`
- removes Protonium config and state
- keeps `~/.vpns`

Delete downloaded VPN configs too:

```bash
./uninstall.sh --purge-vpns
```

Other options:

```text
--yes
--keep-nm
--keep-config
```

---
## Troubleshooting

```bash
protonium-cli status
systemctl --user status protonium-rotate.timer
journalctl --user -u protonium-rotate.service
protonium-cli sync
```

---
## License

MIT. See `LICENSE`.

---
made with blabla.. by blablabla... ya ya yah i am the one.
