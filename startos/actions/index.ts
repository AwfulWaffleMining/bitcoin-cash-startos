import { sdk } from '../sdk'
import { config } from './config'
import { syncConfirm } from './syncConfirm'

export const actions = sdk.Actions.of().addAction(config).addAction(syncConfirm)
