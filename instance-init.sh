#!/bin/bash

set -o errexit
set -o xtrace

main() {
  install_apt_deps
  install_docker
  install_awsmon

  configure_iptables_rules
  create_and_enable_iptables_service
}

install_apt_deps() {
  echo "INFO:
  Installing APT dependencies.
  "

  sudo apt update -y
  sudo apt install -y iptables
}

install_docker() {
  echo "INFO:
  Installing docker.
  "

  curl -fsSL get.docker.com -o get-docker.sh
  sudo sh ./get-docker.sh
}

install_awsmon() {
  echo "INFO:
  Installing awsmon.
  "

  curl -SL \
    -o ./awsmon.tgz \
    https://github.com/cirocosta/awsmon/releases/download/v2.8.1/awsmon_2.8.1_linux_amd64.tar.gz
  tar xzf ./awsmon.tgz
  sudo mv ./awsmon /usr/local/bin/awsmon

  echo "INFO:
  Configuring AWSMON service.
  "

  echo "[Unit]
Description=AWSMON

[Service]
User=root
ExecStart=/usr/local/bin/awsmon --aws --aws-region=sa-east-1 --aws-instance-id=inst1 --aws-instance-type=t2.micro --aws-asg=asg
Restart=always
RestartSec=15

[Install]
WantedBy=multi-user.target" | sudo tee \
    --append /etc/systemd/system/awsmon.service
  sudo systemctl enable awsmon.service
  sudo systemctl start awsmon.service
}

configure_iptables_rules() {
  echo "INFO:
  Configuring IPTABLES rules.
  "

  echo "*filter
:DOCKER-USER - [0:0]

-F DOCKER-USER
-I DOCKER-USER --dest 169.254.169.254 -j REJECT
-A DOCKER-USER -j RETURN

COMMIT" | sudo tee \
    --append /etc/iptables.conf
}

create_and_enable_iptables_service() {
  echo "INFO:
  Configuring IPTABLES service.
  "

  echo "[Unit]
Description=Restore iptables firewall rules
After=network.target docker.service

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
