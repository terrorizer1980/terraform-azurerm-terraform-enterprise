#!/bin/bash

set -e -u -o pipefail

# Set intial start time - used to calculate total time
SECONDS=0 #Start Time

mkdir -p /etc/mitmproxy

touch /etc/systemd/system/mitmproxy.service
chown root:root /etc/systemd/system/mitmproxy.service
chmod 0644 /etc/systemd/system/mitmproxy.service

cat <<EOF >/etc/systemd/system/mitmproxy.service
[Unit]
Description=mitmproxy
ConditionPathExists=/etc/mitmproxy
[Service]
ExecStart=/usr/local/bin/mitmdump -p ${http_proxy_port} --set confdir=/etc/mitmproxy --ssl-insecure
Restart=always
[Install]
WantedBy=multi-user.target
EOF

echo "[$(date +"%FT%T")]  Downloading mitmproxy tar from the web"
curl -Lo /tmp/mitmproxy.tar.gz https://snapshots.mitmproxy.org/6.0.2/mitmproxy-6.0.2-linux.tar.gz
tar xvf /tmp/mitmproxy.tar.gz -C /usr/local/bin/

echo "[$(date +"%FT%T")]  Deploying certificates for mitmproxy"
cat <<EOF >/etc/mitmproxy/mitmproxy-ca.pem
${certificate}
${private_key}
EOF

echo "[$(date +"%FT%T")]  Starting mitmproxy service"
systemctl daemon-reload
systemctl start mitmproxy
systemctl enable mitmproxy

duration=$SECONDS #Stop Time
echo "[$(date +"%FT%T")]  Finished mitmproxy startup script."
echo "  $(($duration / 60)) minutes and $(($duration % 60)) seconds elapsed."