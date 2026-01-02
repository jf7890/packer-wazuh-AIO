#!/usr/bin/env bash
set -euo pipefail

# Silence service operations to avoid occupying SSH session.
export DEBIAN_FRONTEND=noninteractive

echo "[+] Updating apt cache..."
apt-get update -y >/dev/null 2>&1 || true

echo "[+] Installing prerequisites..."
apt-get install -y curl gnupg apt-transport-https lsb-release ca-certificates >/dev/null 2>&1 || true

# ---- Wazuh manager install (official repo flow) ----
# NOTE: This script assumes Internet access from the VM during build.
echo "[+] Adding Wazuh repository..."
curl -s https://packages.wazuh.com/key/GPG-KEY-WAZUH | gpg --dearmor -o /usr/share/keyrings/wazuh.gpg >/dev/null 2>&1 || true
echo "deb [signed-by=/usr/share/keyrings/wazuh.gpg] https://packages.wazuh.com/4.x/apt/ stable main" > /etc/apt/sources.list.d/wazuh.list

apt-get update -y >/dev/null 2>&1 || true

echo "[+] Installing wazuh-manager..."
apt-get install -y wazuh-manager >/dev/null 2>&1 || true

# Start/enable quietly
systemctl enable wazuh-manager >/dev/null 2>&1 || true
systemctl start wazuh-manager >/dev/null 2>&1 || true

# ---- Filebeat install (kept disabled until cert/indexer is ready) ----
echo "[+] Installing filebeat..."
apt-get install -y filebeat >/dev/null 2>&1 || true

mkdir -p /etc/filebeat/certs >/dev/null 2>&1 || true
: > /etc/filebeat/certs/EMPTY_CERT.pem

cat >/root/WAZUH_CERTS_NOTE.txt <<'EOF'
Cert placeholder created:
- /etc/filebeat/certs/EMPTY_CERT.pem

Replace with real cert/key/CA paths once your Wazuh indexer/certs plan is ready,
then enable and start filebeat:
  systemctl enable filebeat
  systemctl start filebeat
EOF

systemctl disable filebeat >/dev/null 2>&1 || true
systemctl stop filebeat >/dev/null 2>&1 || true

echo "[+] Done."
