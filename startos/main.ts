import { sdk } from './sdk'

export const main = sdk.setupMain(async ({ effects }) => {
  console.info('Starting Bitcoin Cash Node...')

  return sdk.Daemons.of(effects).addDaemon('bitcoind', {
    subcontainer: await sdk.SubContainer.of(
      effects,
      { imageId: 'bitcoin-cash' },
      sdk.Mounts.of().mountVolume({
        volumeId: 'main',
        subpath: null,
        mountpoint: '/data',
        readonly: false,
      }),
      'bitcoind',
    ),
    exec: {
      command: ['/usr/local/bin/entrypoint.sh'],
    },
    ready: {
      display: 'Bitcoin Cash Node',
      fn: () =>
        sdk.healthCheck.checkPortListening(effects, 9002, {
          successMessage: 'RPC interface is ready',
          errorMessage: 'RPC interface is not yet ready',
        }),
    },
    requires: [],
  })
})
