#!/bin/bash
set -e
mkdir -p /data/bitcoin-cash

# Write bitcoin.conf from env vars
cat > /data/bitcoin-cash/bitcoin.conf <<EOF
server=1
prune=${BCH_PRUNE:-0}
rpcuser=bchuser
rpcpassword=bchpass123
rpcbind=0.0.0.0
rpcport=9002
rpcallowip=0.0.0.0/0
port=8333
zmqpubhashblock=tcp://0.0.0.0:7002
zmqpubrawblock=tcp://0.0.0.0:7003
maxconnections=${BCH_MAXCONN:-20}
dbcache=${BCH_DBCACHE:-512}
EOF

echo "[bitcoin-cash] Starting bitcoind..."
exec bitcoind -datadir=/data/bitcoin-cash -conf=/data/bitcoin-cash/bitcoin.conf
