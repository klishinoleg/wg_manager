SHELL := /bin/bash

.PHONY: install setup add remove list qr status install-monitor monitor help show

install-monitor:
	@bash scripts/install_monitor.sh

monitor:
	@echo ""
	@echo "Monitor URL:"
	@echo "http://$$(curl -4 -s https://api.ipify.org):10086"
	@echo ""


install:
	@bash install.sh

setup:
	@bash setup.sh

add:
	@bash scripts/add_client.sh $(PROFILE)

remove:
	@bash scripts/remove_client.sh

list:
	@ls -1 /etc/wireguard/clients 2>/dev/null | sed 's/\.conf//' || echo "No clients"

qr:
	@bash scripts/show_qr.sh

status:
	@bash scripts/status.sh

help:
	@echo ""
	@echo "WireGuard Manager"
	@echo "=================="
	@echo "make install          Install packages"
	@echo "make setup            Setup WireGuard"
	@echo "make add PROFILE=name Add client"
	@echo "make remove           Remove client"
	@echo "make list             List clients"
	@echo "make qr               Show QR"
	@echo "make status           Show status"
	@echo ""

show:
	@bash scripts/show_conf.sh

