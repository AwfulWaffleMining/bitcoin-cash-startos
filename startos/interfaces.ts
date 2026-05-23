import { sdk } from './sdk'

export const setInterfaces = sdk.setupInterfaces(async ({ effects }) => {
  const host = sdk.MultiHost.of(effects, 'main')

  const p2pOrigin = await host.bindPort(8333, {
    protocol: null,
    addSsl: null,
    preferredExternalPort: 8333,
    secure: { ssl: false },
  })
  const p2p = sdk.createInterface(effects, {
    name: 'P2P Network',
    id: 'p2p',
    description: 'Bitcoin Cash peer-to-peer network port',
    type: 'api',
    masked: false,
    schemeOverride: null,
    username: null,
    path: '',
    query: {},
  })
  const p2pReceipt = await p2pOrigin.export([p2p])

  return [p2pReceipt]
})
