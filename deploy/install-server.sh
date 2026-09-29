#!/bin/sh
# Sluurp on a fresh Ubuntu or Debian server, as a service behind Caddy (HTTPS
# by itself once a domain points here). Run as root; cloud-init.yaml runs it.
#
#   curl -fsSL https://raw.githubusercontent.com/SluurpHQ/releases/main/deploy/install-server.sh | sh
#
# Settings, from /etc/sluurp.env when it is there:
#   DOMAIN          the name pointed at this server (none: plain HTTP on port 80)
#   ADMIN_EMAIL     the first superuser, made at once (with ADMIN_PASSWORD)
#   ADMIN_PASSWORD
#   SLUURP_LICENSE  a commercial licence key, when the server is used commercially
set -eu

[ -f /etc/sluurp.env ] && . /etc/sluurp.env
DOMAIN="${DOMAIN:-}"

export DEBIAN_FRONTEND=noninteractive
apt-get update -q
apt-get install -y -q curl ca-certificates caddy

# The binary, where every user finds it.
curl -fsSL https://raw.githubusercontent.com/SluurpHQ/releases/main/install.sh | SLUURP_INSTALL=/usr/local sh

# Its own user, data and app folder.
id sluurp >/dev/null 2>&1 || useradd --system --home /srv/sluurp --shell /usr/sbin/nologin sluurp
mkdir -p /srv/sluurp/data /srv/sluurp/app
chown -R sluurp:sluurp /srv/sluurp

if [ -n "${ADMIN_EMAIL:-}" ] && [ -n "${ADMIN_PASSWORD:-}" ]; then
  runuser -u sluurp -- /usr/local/bin/sluurp --dir /srv/sluurp/data superuser "$ADMIN_EMAIL" "$ADMIN_PASSWORD"
fi

touch /etc/sluurp.env
chmod 600 /etc/sluurp.env
# Room for many connections: a long accept queue, all local ports for
# outgoing requests, and TIME_WAIT sockets reused.
cat > /etc/sysctl.d/90-sluurp.conf <<'SYSCTL'
net.core.somaxconn = 8192
net.ipv4.tcp_max_syn_backlog = 8192
net.ipv4.ip_local_port_range = 1024 65535
net.ipv4.tcp_tw_reuse = 1
fs.file-max = 2097152
SYSCTL
sysctl --system >/dev/null

cat > /etc/systemd/system/sluurp.service <<'UNIT'
[Unit]
Description=Sluurp
After=network-online.target
Wants=network-online.target

[Service]
User=sluurp
EnvironmentFile=/etc/sluurp.env
ExecStart=/usr/local/bin/sluurp --dir /srv/sluurp/data serve --addr 127.0.0.1:8090 --public /srv/sluurp/app --no-hot-reload
Restart=always
RestartSec=2
LimitNOFILE=1048576

[Install]
WantedBy=multi-user.target
UNIT
systemctl daemon-reload
systemctl enable --now sluurp

# HTTPS for the domain, by Caddy; without one, plain HTTP on port 80.
site="${DOMAIN:-:80}"
cat > /etc/caddy/Caddyfile <<CADDY
$site {
	encode zstd gzip
	reverse_proxy 127.0.0.1:8090 {
		lb_try_duration 10s
	}
}
CADDY
systemctl reload caddy || systemctl restart caddy

echo "Sluurp is running: https://${DOMAIN:-this-server}/_/ for the admin."
