#!/bin/bash
set -e

echo "Updating system..."
apt update -y

echo "Installing packages..."
apt install -y wireguard qrencode curl git

echo "Enabling IP forwarding..."
sysctl -w net.ipv4.ip_forward=1
grep -q "net.ipv4.ip_forward=1" /etc/sysctl.conf || \
    echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf

echo "Install complete."
