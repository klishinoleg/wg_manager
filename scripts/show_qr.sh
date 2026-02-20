#!/bin/bash

CLIENTS_DIR="/etc/wireguard/clients"

mapfile -t profiles < <(ls -1 "$CLIENTS_DIR" 2>/dev/null | sed 's/\.conf//')

if [ ${#profiles[@]} -eq 0 ]; then
    echo "No profiles found"
    exit 1
fi

echo ""
echo "Select profile:"
select PROFILE in "${profiles[@]}"; do
    if [ -z "$PROFILE" ]; then
        echo "Invalid selection"
        continue
    fi

    CONF_FILE="$CLIENTS_DIR/$PROFILE.conf"

    echo ""
    echo "Profile: $PROFILE"
    echo "Config file: $CONF_FILE"
    echo ""

    if ! command -v qrencode >/dev/null 2>&1; then
        echo "qrencode not installed"
        exit 1
    fi

    qrencode -t ansiutf8 < "$CONF_FILE"

    echo ""
    break
done
