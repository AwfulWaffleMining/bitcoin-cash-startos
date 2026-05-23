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
    long: 'Bitcoin Cash Node (BCHN) is a full node implementation of the Bitcoin Cash protocol. Required by CKPool BCH for solo mining block templates.',
  },
  volumes: ['main'],
  images: {
    'bitcoin-cash': {
      source: { dockerBuild: {} },
      arch: ['x86_64'],
    },
  },
  alerts: {
    install: 'Initial blockchain sync can take several days.',
    update: null,
    uninstall: 'Uninstalling will delete all blockchain data.',
    restore: null,
    start: null,
    stop: 'Services depending on this node will lose connection.',
  },
  dependencies: {},
})
