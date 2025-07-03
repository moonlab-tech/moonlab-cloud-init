#!/bin/bash

RUNBY="nobody"
GROUP="nogroup"

# Check if --require-root is passed as the first argument
if [[ "$1" == "--require-root" ]]; then
  echo "node_exporter will be run as root"
  RUNBY="root"
  GROUP="root"
fi

echo "Installing node_exporter..."
echo "Install wget and tar if not installed..."
sudo apt-get update
sudo apt-get install -y wget tar

VERSION="1.9.1"
OS=$(uname -s | tr '[:upper:]' '[:lower:]')
ARCH=$(uname -m)
case "$ARCH" in
  x86_64) ARCH="amd64" ;;
  aarch64) ARCH="arm64" ;;
  armv7l) ARCH="armv7" ;;
esac
echo $ARCH

echo "Downloading node_exporter ${VERSION} for ${OS} ${ARCH}..."

sudo wget https://github.com/prometheus/node_exporter/releases/download/v${VERSION}/node_exporter-${VERSION}.${OS}-${ARCH}.tar.gz
sudo tar xvfz node_exporter-${VERSION}.${OS}-${ARCH}.tar.gz
cd node_exporter-${VERSION}.${OS}-${ARCH}
sudo mv node_exporter /usr/local/bin/

# Create systemd service file for node_exporter
sudo tee /etc/systemd/system/node_exporter.service > /dev/null <<EOF
[Unit]
Description=Prometheus node_exporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=${RUNBY}
Group=${GROUP}
ExecStart=/usr/local/bin/node_exporter
Restart=on-failure
RestartSec=5s

[Install]
WantedBy=default.target
EOF

sudo systemctl daemon-reload
echo "Enabling node_exportter with following command: sudo systemctl enable node_exporter"
