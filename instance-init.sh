#!/bin/bash

set -o errexit
set -o xtrace

main () {
  install_apt_deps
  install_docker

  configure_iptables_rules
  create_and_enable_iptables_service
}

install_apt_deps () {
  echo "INFO:
  Installing APT dependencies.
  "

  sudo apt update -y
  sudo apt install -y iptables
}

install_docker () {
  echo "INFO:
  Installing docker.
  "

  curl -fsSL get.docker.com -o get-docker.sh
  sudo sh ./get-docker.sh
}

configure_iptables_rules () {
  echo "INFO:
  Configuring IPTABLES rules.
  "

  echo "*filter
:DOCKER-USER - [0:0]

-F DOCKER-USER
-A DOCKER-USER --dest 169.254.169.254 -j DROP
-A DOCKER-USER -j RETURN

COMMIT" | sudo tee \
    --append /etc/iptables.conf
}

create_and_enable_iptables_service () {
  echo "INFO:
  Configuring IPTABLES service.
  "

  echo "[Unit]
Description=Restore iptables firewall rules
Before=network-pre.target

[Service]
Type=oneshot
ExecStart=/sbin/iptables-restore -n /etc/iptables.conf

[Install]
WantedBy=multi-user.target" | sudo tee \
    --append /etc/systemd/system/iptables.service
  sudo systemctl enable iptables.service
  sudo systemctl start iptables.service
}

main
