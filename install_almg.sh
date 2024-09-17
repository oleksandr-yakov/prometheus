#!/bin/bash
#--------------------------------------------------------------------
# Script to Install Prometheus Alertmanager on Linux
# Tested on Ubuntu 22.04, 24.04, Amazon Linux 2023
#--------------------------------------------------------------------
# https://github.com/prometheus/alertmanager/releases

ALERTMANAGER_VERSION="0.27.0"
ALERTMANAGER_FOLDER_CONFIG="/etc/alertmanager"

cd /tmp
wget https://github.com/prometheus/alertmanager/releases/download/v$ALERTMANAGER_VERSION/alertmanager-$ALERTMANAGER_VERSION.linux-amd64.tar.gz

tar xvfz alertmanager-$ALERTMANAGER_VERSION.linux-amd64.tar.gz
cd alertmanager-$ALERTMANAGER_VERSION.linux-amd64


mv alertmanager /usr/bin/
mkdir -p $ALERTMANAGER_FOLDER_CONFIG
mkdir -p $ALERTMANAGER_FOLDER_CONFIG/data
mv alertmanager.yml $ALERTMANAGER_FOLDER_CONFIG

rm -rf /tmp/alertmanager*

useradd -rs /bin/false alertmanager
chown alertmanager:alertmanager /usr/bin/alertmanager
chown alertmanager:alertmanager $ALERTMANAGER_FOLDER_CONFIG
chown alertmanager:alertmanager $ALERTMANAGER_FOLDER_CONFIG/data
chown alertmanager:alertmanager $ALERTMANAGER_FOLDER_CONFIG/alertmanager.yml

cat <<EOF> /etc/systemd/system/alertmanager.service
[Unit]
Description=Prometheus Alertmanager
After=network.target
 
[Service]
User=alertmanager
Group=alertmanager
Type=simple
Restart=on-failure
ExecStart=/usr/bin/alertmanager \
  --config.file       ${ALERTMANAGER_FOLDER_CONFIG}/alertmanager.yml \
  --storage.path      ${ALERTMANAGER_FOLDER_CONFIG}/data
 
[Install]
WantedBy=multi-user.target
EOF

sudo systemctl daemon-reload
sudo systemctl start alertmanager
sudo systemctl enable alertmanager
sudo systemctl status alertmanager
alertmanager --version