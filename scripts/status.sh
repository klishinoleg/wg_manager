#!/bin/bash

WG_INTERFACE="wg0"
REFRESH=3
ONLINE_THRESHOLD=120

while true; do
    clear
    echo ""
    echo "WireGuard Live Monitor ($(date))"
    echo "=========================================================================="
    printf "%-15s %-15s %-10s %-12s %-12s %-12s\n" \
    "Profile" "VPN IP" "Status" "Last Seen" "RX" "TX"
    echo "--------------------------------------------------------------------------"

    NOW=$(date +%s)

    wg show "$WG_INTERFACE" dump | tail -n +2 | while read -r PUBKEY PSK ENDPOINT ALLOWED_IPS LATEST_HANDSHAKE RX TX KEEPALIVE
    do
        PROFILE=$(grep -l "$PUBKEY" /etc/wireguard/keys/*.pub 2>/dev/null | \
                  sed 's#.*/##' | sed 's/.pub//')

        [[ -z "$PROFILE" ]] && PROFILE="unknown"

        if [[ "$LATEST_HANDSHAKE" == "0" ]]; then
            STATUS="OFFLINE"
            LAST_SEEN="never"
        else
            DIFF=$((NOW - LATEST_HANDSHAKE))

            if (( DIFF <= ONLINE_THRESHOLD )); then
                STATUS="ONLINE"
            else
                STATUS="OFFLINE"
            fi

            if (( DIFF < 60 )); then
                LAST_SEEN="${DIFF}s"
            elif (( DIFF < 3600 )); then
                LAST_SEEN="$((DIFF/60))m"
            else
                LAST_SEEN="$((DIFF/3600))h"
            fi
        fi

        RX_H=$(numfmt --to=iec "$RX" 2>/dev/null)
        TX_H=$(numfmt --to=iec "$TX" 2>/dev/null)

        printf "%-15s %-15s %-10s %-12s %-12s %-12s\n" \
            "$PROFILE" "$ALLOWED_IPS" "$STATUS" "$LAST_SEEN" "$RX_H" "$TX_H"

    done

    echo "=========================================================================="
    echo "Refresh every ${REFRESH}s | Ctrl+C to exit"
    sleep $REFRESH
done

