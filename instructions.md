# Bitcoin Cash Node — Setup Instructions

## Overview

Bitcoin Cash Node (BCHN v29.0.1) is a full node implementation of the Bitcoin Cash protocol. This package runs a fully validating BCH node on your StartOS server.

## Installation Order

1. **Install Bitcoin Cash Node first** (this package)
2. Wait for initial blockchain sync — this can take **several days**
3. Install CKPool BCH only after the node is fully synced

## Port Reference

| Port | Protocol | Purpose                |
|------|----------|------------------------|
| 8333 | TCP      | P2P network (exposed)  |
| 9002 | TCP      | RPC (internal only)    |
| 7002 | TCP      | ZMQ hashblock (internal) |
| 7003 | TCP      | ZMQ rawblock (internal)  |

## Configuration Options

Via the **Configure** action in the StartOS UI:

- **Prune Mode (MB):** Set to `0` for a full node (stores entire blockchain). Set to `550` or higher to limit disk usage. **Note:** A pruned node cannot serve historical blocks to other nodes.
- **Database Cache (MB):** More cache speeds up initial sync. Default is 512 MB. Increase if your server has extra RAM.
- **Max Connections:** Number of peer connections. Default is 20. Reduce if bandwidth is limited.

## Pruning vs Full Node

| Mode       | Disk Usage | Block History | Mining Support |
|------------|------------|---------------|----------------|
| Full node  | ~200+ GB   | Complete      | Yes            |
| Pruned     | ~2–5 GB    | Recent only   | Yes            |

CKPool BCH works with both pruned and full nodes.

## Services That Depend on This Node

- **CKPool BCH** — Solo mining stratum server. Requires this node to be running and synced.

## Alerts

- **On install:** Sync can take days. The node is operational during sync but some data may be incomplete.
- **On stop:** CKPool BCH and any dependent services will lose their connection.
- **On uninstall:** All blockchain data is deleted. You will need to re-sync from scratch.
