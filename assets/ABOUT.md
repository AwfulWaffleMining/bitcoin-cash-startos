# Bitcoin Cash Node

Bitcoin Cash Node (BCHN) is a full node implementation of the Bitcoin Cash (BCH) protocol. It validates all transactions and blocks, connects to the BCH peer-to-peer network, and provides an RPC interface used by mining software and wallets.

## Why Run a Full Node?

- **Sovereignty:** Verify your own transactions without trusting a third party
- **Mining:** Required by CKPool BCH for solo mining block templates
- **Privacy:** Your transaction queries stay on your own server

## Sync Time

Initial blockchain sync takes several days depending on your hardware and internet speed. The node is operational during sync but some services (like CKPool BCH) require a fully synced chain before starting.

## Storage

The full BCH blockchain requires approximately 200 GB of storage. Enable pruning in the config action to limit storage usage (minimum 550 MB).

## Upstream

- [BCHN Repository](https://github.com/bitcoin-cash-node/bitcoin-cash-node)
- [BCHN Documentation](https://docs.bitcoincashnode.org/)
