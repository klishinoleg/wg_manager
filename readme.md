# WireGuard Manager

A simple Bash-based manager for deploying and administering a WireGuard
VPN server on Ubuntu/Debian systems.

## Features

-   One-command installation
-   Automatic key generation
-   Automatic NAT + IP forwarding setup
-   Easy client add/remove
-   QR code output for mobile devices
-   Status check
-   Optional web monitor setup

------------------------------------------------------------------------

## Requirements

-   Ubuntu / Debian
-   Root access
-   Public IPv4 address
-   apt package manager

------------------------------------------------------------------------

## Quick Start

### 1. Clone repository

git clone `<your-repo-url>`{=html} cd wg_manager

### 2. Install dependencies

make install

Installs: - wireguard - qrencode - curl - git

Enables IP forwarding automatically.

------------------------------------------------------------------------

### 3. Setup WireGuard server

make setup

This will: - Create /etc/wireguard - Generate server keys - Create
wg0.conf - Configure NAT via iptables - Enable and start wg-quick@wg0 -
Print server public key and endpoint

Default configuration: - VPN subnet: 10.8.0.0/24 - Server address:
10.8.0.1 - Port: 51820 - Interface: wg0

------------------------------------------------------------------------

## Client Management

### Add client

make add PROFILE=name

Example: make add PROFILE=iphone

------------------------------------------------------------------------

### Remove client

make remove

------------------------------------------------------------------------

### List clients

make list

------------------------------------------------------------------------

### Show QR code

make qr

------------------------------------------------------------------------

### Show client config

make show

------------------------------------------------------------------------

## Server Status

make status

------------------------------------------------------------------------

## Monitor

Install monitor:

make install-monitor

Show monitor URL:

make monitor

------------------------------------------------------------------------

## Project Structure

wg_manager/ │ ├── Makefile ├── install.sh ├── setup.sh └── scripts/ ├──
add_client.sh ├── remove_client.sh ├── show_qr.sh ├── show_conf.sh ├──
status.sh └── install_monitor.sh

------------------------------------------------------------------------

## Security Notes

-   /etc/wireguard permissions: 700
-   wg0.conf permissions: 600
-   Private keys stored securely
-   NAT applied only to VPN subnet

------------------------------------------------------------------------

## Manual Restart

systemctl restart wg-quick@wg0

Check logs:

journalctl -u wg-quick@wg0 -f

------------------------------------------------------------------------

## License

MIT
