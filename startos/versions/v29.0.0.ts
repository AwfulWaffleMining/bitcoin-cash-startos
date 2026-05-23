import { VersionInfo, IMPOSSIBLE } from '@start9labs/start-sdk'

export const v_29_0_0 = VersionInfo.of({
  version: '29.0.0:0',
  releaseNotes: {
    en_US: 'Initial StartOS release of Bitcoin Cash Node (BCHN) v29.0.1.',
  },
  migrations: {
    up: async ({ effects }) => {},
    down: IMPOSSIBLE,
  },
})
