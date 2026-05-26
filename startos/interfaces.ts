import { sdk } from './sdk'

export const setInterfaces = sdk.setupInterfaces(async ({ effects }) => {
  // ── P2P ────────────────────────────────────────────────────────────────────
  const p2pMulti = sdk.MultiHost.of(effects, 'p2p')
  const p2pOrigin = await p2pMulti.bindPort(8333, {
    protocol: null,
    addSsl: null,
    preferredExternalPort: 8333,
    secure: { ssl: false },
  })
  const p2p = sdk.createInterface(effects, {
    name: 'Peer Interface',
    id: 'p2p',
    description:
      'Listens for incoming connections from peers on the Bitcoin Cash network',
    type: 'p2p',
    masked: false,
    schemeOverride: { ssl: null, noSsl: null },
    username: null,
    path: '',
    query: {},
  })
  const p2pReceipt = await p2pOrigin.export([p2p])

  // ── RPC ────────────────────────────────────────────────────────────────────
  const rpcMulti = sdk.MultiHost.of(effects, 'rpc')
  const rpcOrigin = await rpcMulti.bindPort(9002, {
    protocol: null,
    addSsl: null,
    preferredExternalPort: 9002,
    secure: { ssl: false },
  })
  const rpc = sdk.createInterface(effects, {
    name: 'RPC Interface',
    id: 'rpc',
    description: 'Listens for JSON-RPC commands from wallets and services',
    type: 'api',
    masked: false,
    schemeOverride: { ssl: null, noSsl: 'http' },
    username: null,
    path: '/',
    query: {},
  })
  const rpcReceipt = await rpcOrigin.export([rpc])

  // ── ZeroMQ ─────────────────────────────────────────────────────────────────
  const zmqMulti = sdk.MultiHost.of(effects, 'zmq')
  const zmqOrigin = await zmqMulti.bindPort(7002, {
    protocol: null,
    addSsl: null,
    preferredExternalPort: 28332,
    secure: { ssl: false },
  })
  const zmq = sdk.createInterface(effects, {
    name: 'ZeroMQ Interface',
    id: 'zmq',
    description:
      'Publishes block and transaction notifications to subscribing services',
    type: 'api',
    masked: false,
    schemeOverride: { ssl: null, noSsl: null },
    username: null,
    path: '',
    query: {},
  })
  const zmqReceipt = await zmqOrigin.export([zmq])

  return [p2pReceipt, rpcReceipt, zmqReceipt]
})
