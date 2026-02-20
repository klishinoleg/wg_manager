#!/bin/bash
set -e

echo "Installing wg-dashboard..."

apt install -y python3 python3-pip

pip3 install wireguard-dashboard

mkdir -p /etc/wg-dashboard

cat > /etc/systemd/system/wg-dashboard.service <<EOF
[Unit]
Description=WireGuard Dashboard
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/wg-dashboard -p 10086
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable wg-dashboard
systemctl start wg-dashboard

echo ""
echo "wg-dashboard installed."
echo "Open: http://$(curl -4 -s https://api.ipify.org):10086"
