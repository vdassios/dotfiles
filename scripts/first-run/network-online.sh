#!/bin/bash

# Consider the network "online" once ANY link is routable.
# By default systemd-networkd-wait-online waits for every managed link, so the
# br0 bridge (DHCP on wired en*) with no cable plugged in hangs boot for 2 min
# and delays everything ordered after network-online.target (docker, postgres).
sudo mkdir -p /etc/systemd/system/systemd-networkd-wait-online.service.d
sudo tee /etc/systemd/system/systemd-networkd-wait-online.service.d/any.conf >/dev/null <<'EOF'
[Service]
ExecStart=
ExecStart=/usr/lib/systemd/systemd-networkd-wait-online --any
EOF
sudo systemctl daemon-reload
