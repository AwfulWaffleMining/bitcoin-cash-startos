#!/bin/bash
# AWM Mining — Bitcoin (BTC) SHA-256 Mining Setup
# Runs on Hetzner VPS alongside BCH and DGB setups.
# Installs Bitcoin Core, configures ckpool-btc on port 3401.
# BTC takes days to sync fully — start early!

set -e
echo "========================================"
echo " AWM Mining — BTC Setup"
echo "========================================"
echo "Starting at: $(date)"

BTC_VERSION="28.1"
BTC_PAYOUT="${BTC_PAYOUT:-bc1qcm2k0uhqvcwsrcd63xl0kdd3z0pwxc9zjgtv3j}"
STRATUM_PORT=3401

# ── Download Bitcoin Core ─────────────────────────────────────────────────────
echo ""
echo "[1/5] Downloading Bitcoin Core ${BTC_VERSION}..."
cd /tmp
wget -q "https://bitcoincore.org/bin/bitcoin-core-${BTC_VERSION}/bitcoin-${BTC_VERSION}-x86_64-linux-gnu.tar.gz" \
  -O btc.tar.gz
tar -xzf btc.tar.gz
cp bitcoin-${BTC_VERSION}/bin/bitcoind /usr/local/bin/bitcoind-btc
cp bitcoin-${BTC_VERSION}/bin/bitcoin-cli /usr/local/bin/bitcoin-cli-btc
rm -rf btc.tar.gz bitcoin-${BTC_VERSION}
echo "  ✅ Bitcoin Core ${BTC_VERSION} installed"

# ── Configure Bitcoin node (pruned to save disk) ──────────────────────────────
echo ""
echo "[2/5] Configuring Bitcoin node..."
mkdir -p /data/btc
cat > /data/btc/bitcoin.conf << EOF
server=1
prune=2000
rpcuser=btcuser
rpcpassword=btcpass123
rpcbind=0.0.0.0
rpcport=9001
rpcallowip=0.0.0.0/0
port=8334
zmqpubhashblock=tcp://0.0.0.0:7001
zmqpubrawblock=tcp://0.0.0.0:7000
maxconnections=20
dbcache=2048
EOF

cat > /etc/systemd/system/bitcoind-btc.service << 'EOF'
[Unit]
Description=Bitcoin Core Node
After=network.target

[Service]
ExecStart=/usr/local/bin/bitcoind-btc -datadir=/data/btc -conf=/data/btc/bitcoin.conf -daemon=0
Restart=on-failure
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable bitcoind-btc
systemctl start bitcoind-btc
echo "  ✅ Bitcoin node started (syncing... this takes 1-3 days)"

# ── Configure ckpool-btc ──────────────────────────────────────────────────────
echo ""
echo "[3/5] Configuring ckpool for BTC..."
mkdir -p /data/ckpool-btc/logs
cat > /data/ckpool-btc/ckpool-btc.conf << EOF
{
"btcd" : [
  {
    "url"    : "127.0.0.1:9001",
    "auth"   : "btcuser",
    "pass"   : "btcpass123",
    "notify" : true
  }
],
"btcaddress"      : "${BTC_PAYOUT}",
"btcsig"          : "/AwfulWaffle-BTC/",
"blockpoll"       : 100,
"nonce1length"    : 4,
"nonce2length"    : 8,
"update_interval" : 30,
"version_mask"    : "1fffe000",
"serverurl"       : [
  "0.0.0.0:${STRATUM_PORT}"
],
"mindiff"         : 512,
"startdiff"       : 4096,
"zmqblock"        : "tcp://127.0.0.1:7001",
"logdir"          : "/data/ckpool-btc/logs"
}
EOF

cat > /etc/systemd/system/ckpool-btc.service << 'EOF'
[Unit]
Description=AWM Mining ckpool BTC Stratum
After=network.target bitcoind-btc.service

[Service]
ExecStartPre=/bin/bash -c 'until /usr/local/bin/bitcoin-cli-btc -datadir=/data/btc -rpcuser=btcuser -rpcpassword=btcpass123 getblockchaininfo 2>/dev/null | grep -q "\"initialblockdownload\": false"; do echo "Waiting for BTC sync..."; sleep 60; done'
ExecStart=/usr/local/bin/ckpool --config /data/ckpool-btc/ckpool-btc.conf
Restart=on-failure
RestartSec=30

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable ckpool-btc
echo "  ✅ ckpool-btc configured (starts when BTC syncs)"

# ── Firewall ──────────────────────────────────────────────────────────────────
echo ""
echo "[4/5] Opening port ${STRATUM_PORT}..."
ufw allow ${STRATUM_PORT}/tcp
echo "  ✅ Port ${STRATUM_PORT} open"

# ── Done ─────────────────────────────────────────────────────────────────────
echo ""
echo "[5/5] Done!"
echo ""
echo "========================================"
echo " BTC Setup Complete!"
echo "========================================"
echo ""
echo "Chain data:     /data/btc"
echo "RPC:            127.0.0.1:9001 (user: btcuser)"
echo "ZMQ hashblock:  tcp://0.0.0.0:7001"
echo "Stratum port:   ${STRATUM_PORT}"
echo "Payout address: ${BTC_PAYOUT}"
echo ""
echo "⚠️  BTC sync takes 1-3 days. ckpool-btc starts automatically when synced."
echo ""
echo "Check sync:     bitcoin-cli-btc -conf=/data/btc/bitcoin.conf getblockchaininfo"
echo "Check ckpool:   systemctl status ckpool-btc"
echo "Logs:           journalctl -u bitcoind-btc -f"
echo "                journalctl -u ckpool-btc -f"
echo ""
echo "Once synced, connect BTC miners to stratum+tcp://<VPS-IP>:${STRATUM_PORT}"
echo "Username format: your_btc_address.WorkerName"
