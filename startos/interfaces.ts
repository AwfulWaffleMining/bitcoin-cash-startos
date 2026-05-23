import { sdk } from './sdk'

export const setInterfaces = sdk.setupInterfaces(async ({ effects }) => {
  const p2pMulti = sdk.MultiHost.of(effects, 'p2p')
  const p2pOrigin = await p2pMulti.bindPort(8333, {
    protocol: null,
    addSsl: null,
    preferredExternalPort: 8333,
    secure: { ssl: false },
  })
  const p2p = sdk.createInterface(effects, {
    name: 'P2P Network',
    id: 'p2p',
    description: 'Bitcoin Cash peer-to-peer network port',
    type: 'p2p',
    masked: false,
    schemeOverride: { ssl: null, noSsl: null },
    username: null,
    path: '',
    query: {},
  })
  const p2pReceipt = await p2pOrigin.export([p2p])

  return [p2pReceipt]
})
