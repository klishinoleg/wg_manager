#!/bin/bash

WG_DIR="/etc/wireguard"
WG_CONF="$WG_DIR/wg0.conf"
CLIENTS_DIR="$WG_DIR/clients"
KEYS_DIR="$WG_DIR/keys"
WG_INTERFACE="wg0"
SERVER_PUBLIC_KEY=$(cat "$WG_DIR/server.pub")
SERVER_IPV4=$(curl -4 -s https://api.ipify.org)
SERVER_ENDPOINT="$SERVER_IPV4:51820"
VPN_SUBNET="10.8.0"

PROFILE="$1"

if [ -z "$PROFILE" ]; then
    echo "Usage: ./add_client.sh profile_name"
    exit 1
fi

if [ -f "$CLIENTS_DIR/$PROFILE.conf" ]; then
    echo "Profile already exists"
    exit 1
fi

echo "Creating profile: $PROFILE"

# Generate keys
wg genkey | tee "$KEYS_DIR/$PROFILE.key" | wg pubkey > "$KEYS_DIR/$PROFILE.pub"

# Calculate next IP
LAST_IP=$(grep -o '10\.8\.0\.[0-9]*' "$WG_CONF" | awk -F '.' '{print $4}' | sort -n | tail -1)

if [ -z "$LAST_IP" ]; then
    NEXT_IP=2
else
    NEXT_IP=$((LAST_IP + 1))
fi

CLIENT_IP="$VPN_SUBNET.$NEXT_IP"

echo "Assigned IP: $CLIENT_IP"

PUBKEY=$(cat "$KEYS_DIR/$PROFILE.pub")

# Add peer live
wg set "$WG_INTERFACE" peer "$PUBKEY" allowed-ips "$CLIENT_IP/32"

# Backup config
cp "$WG_CONF" "$WG_CONF.bak.$(date +%s)"

# Persist to config
{
    echo ""
    echo "[Peer]"
    echo "PublicKey = $PUBKEY"
    echo "AllowedIPs = $CLIENT_IP/32"
} >> "$WG_CONF"

# Generate client config
cat > "$CLIENTS_DIR/$PROFILE.conf" <<EOF
[Interface]
PrivateKey = $(cat "$KEYS_DIR/$PROFILE.key")
Address = $CLIENT_IP/24
DNS = 1.1.1.1

[Peer]
PublicKey = $SERVER_PUBLIC_KEY
Endpoint = $SERVER_ENDPOINT
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF

echo ""
echo "Client config created: $CLIENTS_DIR/$PROFILE.conf"
echo ""

qrencode -t ansiutf8 < "$CLIENTS_DIR/$PROFILE.conf"
