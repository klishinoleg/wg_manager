#!/bin/bash
set -e

WG_DIR="/etc/wireguard"
VPN_SUBNET="10.8.0"
PORT="51820"
WG_INTERFACE="wg0"

SERVER_IP=$(curl -s ifconfig.me)
MAIN_IF=$(ip route get 8.8.8.8 | awk '{print $5}' | head -n1)

echo "Server IP: $SERVER_IP"
echo "Main interface: $MAIN_IF"

mkdir -p $WG_DIR/{clients,keys}
chmod 700 $WG_DIR

cd $WG_DIR

if [ ! -f server.key ]; then
    echo "Generating server keys..."
    wg genkey | tee server.key | wg pubkey > server.pub
fi

SERVER_PRIVATE_KEY=$(cat server.key)

cat > wg0.conf <<EOF
[Interface]
Address = $VPN_SUBNET.1/24
ListenPort = $PORT
PrivateKey = $SERVER_PRIVATE_KEY

PostUp = iptables -A FORWARD -i $WG_INTERFACE -j ACCEPT
PostUp = iptables -A FORWARD -o $WG_INTERFACE -j ACCEPT
PostUp = iptables -t nat -A POSTROUTING -s $VPN_SUBNET.0/24 -o $MAIN_IF -j MASQUERADE

PostDown = iptables -D FORWARD -i $WG_INTERFACE -j ACCEPT
PostDown = iptables -D FORWARD -o $WG_INTERFACE -j ACCEPT
PostDown = iptables -t nat -D POSTROUTING -s $VPN_SUBNET.0/24 -o $MAIN_IF -j MASQUERADE
EOF

chmod 600 wg0.conf

systemctl enable wg-quick@wg0
systemctl restart wg-quick@wg0

echo ""
echo "WireGuard setup complete."
echo "Public key:"
cat server.pub
echo ""
echo "Endpoint: $SERVER_IP:$PORT"
