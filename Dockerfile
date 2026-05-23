FROM debian:bookworm-slim AS builder
ARG BCHN_VERSION=29.0.1
RUN apt-get update && apt-get install -y wget && rm -rf /var/lib/apt/lists/*
RUN wget -q "https://github.com/bitcoin-cash-node/bitcoin-cash-node/releases/download/v${BCHN_VERSION}/bitcoin-cash-node-${BCHN_VERSION}-x86_64-linux-gnu.tar.gz" \
    -O /tmp/bchn.tar.gz && \
    tar -xzf /tmp/bchn.tar.gz -C /tmp && \
    cp /tmp/bitcoin-cash-node-${BCHN_VERSION}/bin/bitcoind /usr/local/bin/bitcoind && \
    cp /tmp/bitcoin-cash-node-${BCHN_VERSION}/bin/bitcoin-cli /usr/local/bin/bitcoin-cli

FROM debian:bookworm-slim
RUN apt-get update && apt-get install -y --no-install-recommends \
    libboost-filesystem1.74.0 libssl3 libevent-2.1-7 libzmq5 \
    libminiupnpc17 curl python3 && \
    rm -rf /var/lib/apt/lists/*
COPY --from=builder /usr/local/bin/bitcoind /usr/local/bin/bitcoind
COPY --from=builder /usr/local/bin/bitcoin-cli /usr/local/bin/bitcoin-cli
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh
VOLUME ["/data"]
EXPOSE 8333 9002 7002 7003
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
