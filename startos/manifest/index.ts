import { setupManifest } from '@start9labs/start-sdk'

export const manifest = setupManifest({
  id: 'bitcoin-cash',
  title: 'Bitcoin Cash Node',
  license: 'MIT',
  packageRepo: 'https://github.com/AwfulWaffleMining/bitcoin-cash-startos',
  upstreamRepo: 'https://github.com/bitcoin-cash-node/bitcoin-cash-node',
  supportSite: 'https://docs.bitcoincashnode.org/',
  marketingUrl: 'https://bitcoincashnode.org/',
  donationUrl: null,
  description: {
    short: 'Bitcoin Cash full node (BCHN v29.0.1)',
    long: 'Bitcoin Cash Node (BCHN) is a full node implementation of the Bitcoin Cash protocol. It validates all transactions and blocks, enables peer-to-peer BCH transfers with no trusted third parties, and provides an RPC interface used by other services such as CKPool BCH for solo mining. All data is stored locally — you own your node, your keys, your BCH.',
  },
  volumes: ['main'],
  images: {
    'bitcoin-cash': {
      source: { dockerBuild: {} },
      arch: ['x86_64'],
    },
  },
  alerts: {
    install:
      'Initial blockchain sync can take several days. The node will be operational during sync but some features may show incomplete data.',
    update: null,
    uninstall:
      'Uninstalling Bitcoin Cash Node will delete all blockchain data. You will need to re-sync from scratch if you reinstall.',
    restore: null,
    start: null,
    stop: 'CKPool BCH and any other services depending on this node will lose their connection when the node stops.',
  },
  dependencies: {},
})
