# Mieru server deployment (Debian / Ubuntu)

This project installs the **official Mieru server package (`mita`)** from the
`enfein/mieru` GitHub Releases page. It does not modify or recompile upstream
source code.

## Supported environment

- Debian 12/13 or Ubuntu (systemd-based)
- CPU: `amd64` or `arm64`
- Root / sudo access
- An inbound TCP or UDP port allowed by both the VPS provider firewall and
  the operating-system firewall

The default pinned version is `3.39.0`. To install another official release,
set `MIERU_VERSION`, for example:
`sudo MIERU_VERSION=3.39.0 bash install.sh`

## Quick deployment

Upload this folder to a VPS, then run:

```bash
chmod +x install.sh deploy.sh update.sh uninstall.sh
sudo bash deploy.sh
```

The deploy script asks for:
- Listening port (default `8443`)
- Transport (`TCP` or `UDP`, default `TCP`)
- Username (generated if blank)
- Password (generated if blank)

Credentials are saved in `/root/mieru-credentials.txt` with mode `600`.
Copy them securely for your own client setup. Do not commit credentials to Git.

## Firewall

The scripts intentionally do not change provider-side firewall rules.

Allow the selected port and protocol in:
1. Your VPS provider's network/security firewall.
2. The Linux firewall (if enabled).

For UFW, for example, if you selected TCP port 8443:

```bash
sudo ufw allow 8443/tcp
```

For UDP:

```bash
sudo ufw allow 8443/udp
```

If the provider only gives you a port-forwarded or restricted port, use the
actual assigned external port and verify whether TCP/UDP is supported.

## Operations

```bash
sudo systemctl status mita
sudo mita status
sudo mita describe config
sudo journalctl -u mita -n 100 --no-pager
```

Update to the pinned release:

```bash
sudo bash update.sh
```

Update to a specified official release:

```bash
sudo bash update.sh 3.39.0
```

Uninstall (keeps configuration and credentials by default):

```bash
sudo bash uninstall.sh
```

## Important notes

- The official Debian package installs and manages the `mita` systemd service.
  A custom `mita.service` file is not required and should not override it.
- After changing server settings, use `mita stop` and `mita start`, as the
  upstream server guide specifies.
- Keep server and client system clocks synchronized (NTP).
- This package is intended for a compatible VPS where this service is allowed.
  Do not deploy it on a host whose acceptable-use policy prohibits VPN,
  proxy, or tunneling services.
- The `mita` server configuration is applied through `mita replace config`.
  The temporary JSON file is removed after configuration is applied; upstream
  stores its server config in its own managed format.
- Check the upstream documentation before changing versions or configuration:
  https://github.com/enfein/mieru/blob/main/docs/server-install.zh_CN.md
