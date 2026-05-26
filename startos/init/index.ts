import { sdk } from '../sdk'
import { setDependencies } from '../dependencies'
import { setInterfaces } from '../interfaces'
import { versionGraph } from '../versions'
import { actions } from '../actions'
import { restoreInit } from '../backups'
import { syncConfirm } from '../actions/syncConfirm'

const createSyncTask = sdk.setupOnInit(
  async (effects, kind) => {
    if (kind === 'install') {
      await sdk.action.createOwnTask(effects, syncConfirm, 'critical', {
        replayId: 'sync-confirm',
        reason: 'Confirm blockchain sync before starting the node',
      })
    }
  },
)

export const init = sdk.setupInit(
  restoreInit,
  versionGraph,
  setInterfaces,
  setDependencies,
  actions,
  createSyncTask,
)

export const uninit = sdk.setupUninit(versionGraph)
