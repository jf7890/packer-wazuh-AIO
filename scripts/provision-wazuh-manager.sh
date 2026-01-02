#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "[+] Baseline packages..."
apt-get update -y > /dev/null 2>&1 || true
apt-get install -y --no-install-recommends \
  ca-certificates curl gnupg apt-transport-https \
  > /dev/null 2>&1 || true

echo "[+] Add Wazuh APT repository (4.x)..."
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | \
  gpg --no-default-keyring --keyring gnupg-ring:/usr/share/keyrings/wazuh.gpg --import \
  > /dev/null 2>&1
chmod 644 /usr/share/keyrings/wazuh.gpg > /dev/null 2>&1 || true

echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" \
  | tee /etc/apt/sources.list.d/wazuh.list > /dev/null

apt-get update -y > /dev/null 2>&1 || true

echo "[+] Install wazuh-manager + filebeat..."
apt-get install -y wazuh-manager filebeat > /dev/null 2>&1

echo "[+] Install Wazuh Filebeat module (best-effort; URL may change between releases)..."
(curl -fsSL https://packages.wazuh.com/4.x/filebeat/wazuh-filebeat-0.3.tar.gz \
  | tar -xz -C /usr/share/filebeat/module) > /dev/null 2>&1 || true

echo "[+] Deploy Wazuh manager config + local rules..."
install -m 0640 /tmp/ossec.conf /var/ossec/etc/ossec.conf
install -m 0640 /tmp/local_rules.xml /var/ossec/etc/rules/local_rules.xml

echo "[+] Deploy Filebeat config template..."
install -m 0640 /tmp/filebeat.yml /etc/filebeat/filebeat.yml

echo "[+] Create CERT placeholder(s)..."
mkdir -p /etc/filebeat/certs
: > /etc/filebeat/certs/EMPTY_CERT.pem
chmod 0644 /etc/filebeat/certs/EMPTY_CERT.pem

cat > /root/WAZUH_CERTS_NOTE.txt <<'EOF'
This template intentionally ships with EMPTY cert placeholder(s):

  - /etc/filebeat/certs/EMPTY_CERT.pem

Replace these with real TLS certs/keys (typically generated when setting up Wazuh Indexer),
then configure /etc/filebeat/filebeat.yml and enable Filebeat.
EOF
chmod 0644 /root/WAZUH_CERTS_NOTE.txt

echo "[+] Enable wazuh-manager, but keep filebeat disabled by default..."
systemctl daemon-reload > /dev/null 2>&1 || true
systemctl enable wazuh-manager > /dev/null 2>&1 || true
systemctl start wazuh-manager > /dev/null 2>&1 || true

systemctl disable filebeat > /dev/null 2>&1 || true
systemctl stop filebeat > /dev/null 2>&1 || true

echo "[+] Done."
