#!/bin/bash

WG_DIR="/etc/wireguard"
WG_CONF="$WG_DIR/wg0.conf"
CLIENTS_DIR="$WG_DIR/clients"
KEYS_DIR="$WG_DIR/keys"
WG_INTERFACE="wg0"

mapfile -t profiles < <(ls -1 "$CLIENTS_DIR" 2>/dev/null | sed 's/\.conf//')

if [ ${#profiles[@]} -eq 0 ]; then
    echo "No profiles found"
    exit 1
fi

echo "Select profile to remove:"
select PROFILE in "${profiles[@]}"; do
    if [ -z "$PROFILE" ]; then
        echo "Invalid selection"
        continue
    fi

    PUBKEY=$(cat "$KEYS_DIR/$PROFILE.pub")

    echo "Removing $PROFILE..."

    # Remove live peer
    wg set "$WG_INTERFACE" peer "$PUBKEY" remove

    # Backup config
    cp "$WG_CONF" "$WG_CONF.bak.$(date +%s)"

    # Remove peer block safely
    awk -v key="$PUBKEY" '
        BEGIN{skip=0}
        /^\[Peer\]/{block=1; buffer=$0; next}
        block && /PublicKey/{
            if ($3==key){skip=1}
        }
        block{
            buffer=buffer "\n" $0
            if ($0 ~ /^AllowedIPs/){
                if (!skip) print buffer
                block=0
                skip=0
            }
            next
        }
        !block{print}
    ' "$WG_CONF" > "$WG_CONF.tmp" && mv "$WG_CONF.tmp" "$WG_CONF"

    rm -f "$CLIENTS_DIR/$PROFILE.conf"
    rm -f "$KEYS_DIR/$PROFILE.key"
    rm -f "$KEYS_DIR/$PROFILE.pub"

    echo "Removed $PROFILE successfully."
    break
done

