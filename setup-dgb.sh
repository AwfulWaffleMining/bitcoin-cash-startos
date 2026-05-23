#!/bin/bash
# AWM Mining — DigiByte (DGB) SHA-256 Mining Setup
# Runs on Hetzner VPS (Ubuntu 22.04) alongside the existing BCH setup.
# Installs digibyted, configures a second ckpool instance, and opens port 3402.
#
# Usage:
#   bash setup-dgb.sh

set -euo pipefail

echo "============================================"
echo " AWM Mining — DGB Setup (SHA-256)"
echo "============================================"

# ── Config ─────────────────────────────────────────────────────────────────────
DGB_VERSION="8.26.0"
DGB_DATA_DIR="/data/dgb"
DGB_RPC_USER="dgbuser"
DGB_RPC_PASS="dgbpass123"
DGB_RPC_PORT="9332"
DGB_P2P_PORT="12024"
DGB_ZMQ_HASHBLOCK="tcp://0.0.0.0:7004"
DGB_ZMQ_RAWBLOCK="tcp://0.0.0.0:7005"

CKPOOL_DGB_DIR="/data/ckpool-dgb"
CKPOOL_STRATUM_PORT="3402"
DGB_PAYOUT_ADDR="DMHp3aP3fSDx4YnjtXkHpFtrDwGhWaHbT8"

ARCH="x86_64-linux-gnu"
RELEASE_URL="https://github.com/digibyte-core/digibyte/releases/download/v${DGB_VERSION}/digibyte-${DGB_VERSION}-${ARCH}.tar.gz"

# ── Step 1: Install digibyted ──────────────────────────────────────────────────
echo ""
echo "[1/6] Installing DigiByte node v${DGB_VERSION}..."

cd /tmp
TARBALL="digibyte-${DGB_VERSION}-${ARCH}.tar.gz"

if [ ! -f "/usr/local/bin/digibyted" ]; then
  echo "Downloading ${RELEASE_URL}..."
  wget -q --show-progress -O "${TARBALL}" "${RELEASE_URL}"
  tar -xzf "${TARBALL}"
  EXTRACT_DIR="digibyte-${DGB_VERSION}"
  install -m 755 "${EXTRACT_DIR}/bin/digibyted" /usr/local/bin/digibyted
  install -m 755 "${EXTRACT_DIR}/bin/digibyte-cli" /usr/local/bin/digibyte-cli
  rm -rf "${TARBALL}" "${EXTRACT_DIR}"
  echo "digibyted installed: $(digibyted --version | head -1)"
else
  echo "digibyted already installed: $(digibyted --version | head -1)"
fi

# ── Step 2: Create data directory and config ────────────────────────────────────
echo ""
echo "[2/6] Configuring DigiByte node..."

mkdir -p "${DGB_DATA_DIR}"

cat > "${DGB_DATA_DIR}/digibyte.conf" <<EOF
# DigiByte Core config — AWM Mining
server=1
daemon=1
datadir=${DGB_DATA_DIR}

# RPC
rpcuser=${DGB_RPC_USER}
rpcpassword=${DGB_RPC_PASS}
rpcport=${DGB_RPC_PORT}
rpcallowip=127.0.0.1

# Network
port=${DGB_P2P_PORT}
listen=1
maxconnections=32

# No pruning — DGB chain is small (~20 GB)
prune=0
txindex=1

# ZMQ for ckpool
zmqpubhashblock=${DGB_ZMQ_HASHBLOCK}
zmqpubrawblock=${DGB_ZMQ_RAWBLOCK}

# SHA-256 algo selection (DigiByte multi-algo, select sha256d)
algo=sha256d
EOF

echo "Config written to ${DGB_DATA_DIR}/digibyte.conf"

# ── Step 3: Create systemd service for digibyted ───────────────────────────────
echo ""
echo "[3/6] Creating digibyted systemd service..."

cat > /etc/systemd/system/digibyted.service <<EOF
[Unit]
Description=DigiByte Core Daemon
After=network.target
Wants=network.target

[Service]
Type=forking
ExecStart=/usr/local/bin/digibyted -conf=${DGB_DATA_DIR}/digibyte.conf -daemon
ExecStop=/usr/local/bin/digibyte-cli -conf=${DGB_DATA_DIR}/digibyte.conf stop
PIDFile=${DGB_DATA_DIR}/digibyted.pid
Restart=on-failure
RestartSec=30
TimeoutStartSec=120
TimeoutStopSec=60
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable digibyted

echo "digibyted service enabled."

# ── Step 4: Configure ckpool-dgb ───────────────────────────────────────────────
echo ""
echo "[4/6] Configuring ckpool for DGB (stratum port ${CKPOOL_STRATUM_PORT})..."

# Confirm ckpool binary exists (installed by BCH setup)
if ! command -v ckpool &>/dev/null; then
  echo "ERROR: ckpool binary not found. Run the BCH setup script first."
  exit 1
fi

mkdir -p "${CKPOOL_DGB_DIR}/logs"

cat > "${CKPOOL_DGB_DIR}/ckpool-dgb.conf" <<EOF
{
  "btcd": [
    {
      "url": "127.0.0.1:${DGB_RPC_PORT}",
      "auth": "${DGB_RPC_USER}",
      "pass": "${DGB_RPC_PASS}",
      "notify": true
    }
  ],
  "btcaddress": "${DGB_PAYOUT_ADDR}",
  "btcsig": "AWM/DGB",
  "blockpoll": 100,
  "nonce1length": 4,
  "nonce2length": 8,
  "update_interval": 30,
  "serverurl": [
    "0.0.0.0:${CKPOOL_STRATUM_PORT}"
  ],
  "zmqblock": "${DGB_ZMQ_HASHBLOCK}",
  "logdir": "${CKPOOL_DGB_DIR}/logs"
}
EOF

echo "ckpool-dgb config written to ${CKPOOL_DGB_DIR}/ckpool-dgb.conf"

# ── Step 5: Create systemd service for ckpool-dgb ──────────────────────────────
echo ""
echo "[5/6] Creating ckpool-dgb systemd service..."

cat > /etc/systemd/system/ckpool-dgb.service <<EOF
[Unit]
Description=ckpool — DGB SHA-256 stratum server
After=digibyted.service network.target
Wants=digibyted.service

[Service]
Type=simple
ExecStartPre=/bin/bash -c 'until /usr/local/bin/digibyte-cli -conf=${DGB_DATA_DIR}/digibyte.conf getblockchaininfo &>/dev/null; do echo "Waiting for digibyted..."; sleep 5; done'
ExecStart=/usr/bin/ckpool -c ${CKPOOL_DGB_DIR}/ckpool-dgb.conf -l ${CKPOOL_DGB_DIR}/logs
Restart=on-failure
RestartSec=15
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable ckpool-dgb

echo "ckpool-dgb service enabled."

# ── Step 6: Firewall ───────────────────────────────────────────────────────────
echo ""
echo "[6/6] Opening stratum port ${CKPOOL_STRATUM_PORT} in ufw..."

ufw allow ${CKPOOL_STRATUM_PORT}/tcp comment "AWM DGB stratum"
ufw allow ${DGB_P2P_PORT}/tcp comment "DigiByte P2P"
echo "Firewall rules added."

# ── Start services ─────────────────────────────────────────────────────────────
echo ""
echo "Starting digibyted..."
systemctl start digibyted
sleep 3

if systemctl is-active --quiet digibyted; then
  echo "digibyted is running. Waiting for RPC to become available before starting ckpool-dgb..."
  echo "(DGB initial sync can take a few hours — ckpool-dgb will wait automatically via ExecStartPre)"
  systemctl start ckpool-dgb &
  echo "ckpool-dgb service started in background (will retry until node is ready)."
else
  echo "WARNING: digibyted failed to start. Check: journalctl -u digibyted -n 50"
  echo "After fixing, run: systemctl start ckpool-dgb"
fi

echo ""
echo "============================================"
echo " DGB setup complete!"
echo "============================================"
echo ""
echo " Chain data:     ${DGB_DATA_DIR}"
echo " RPC:            127.0.0.1:${DGB_RPC_PORT} (user: ${DGB_RPC_USER})"
echo " ZMQ hashblock:  ${DGB_ZMQ_HASHBLOCK}"
echo " Stratum port:   ${CKPOOL_STRATUM_PORT}"
echo " Payout address: ${DGB_PAYOUT_ADDR}"
echo ""
echo " Check sync:     digibyte-cli -conf=${DGB_DATA_DIR}/digibyte.conf getblockchaininfo"
echo " Check ckpool:   systemctl status ckpool-dgb"
echo " Logs:           journalctl -u digibyted -f"
echo "                 journalctl -u ckpool-dgb -f"
echo ""
echo " Once DGB node is synced, connect SHA-256 miners to stratum+tcp://<VPS-IP>:${CKPOOL_STRATUM_PORT}"
echo ""
