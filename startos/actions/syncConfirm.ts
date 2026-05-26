import { sdk } from '../sdk'

export const syncConfirm = sdk.Action.withoutInput(
  'sync-confirm',

  async ({ effects }) => ({
    name: 'Begin Blockchain Sync',
    description:
      'Bitcoin Cash Node will download and verify the complete BCH blockchain (~250 GB). ' +
      'This process can take several days. ' +
      'CKPool BCH will automatically become available once sync is complete. ' +
      'Click the play button to confirm and proceed.',
    warning: null,
    allowedStatuses: 'any' as const,
    group: null,
    visibility: 'enabled' as const,
  }),

  async ({ effects }) => {
    await sdk.action.clearTask(effects, 'sync-confirm')
    return {
      version: '1' as const,
      title: 'Blockchain Sync Confirmed',
      message: 'Bitcoin Cash Node is ready to start. Press the Start button to begin syncing the blockchain.',
      result: null,
    }
  },
)
