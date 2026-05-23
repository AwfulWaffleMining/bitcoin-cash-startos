import { sdk } from '../sdk'

const { InputSpec, Value } = sdk

export const inputSpec = InputSpec.of({
  prune: Value.number({
    name: 'Prune Mode (MB)',
    description:
      'Set to 0 to disable pruning (full node). Set to 550 or higher to enable pruning and limit blockchain storage.',
    required: false,
    default: 0,
    min: 0,
    integer: true,
    units: 'MB',
  }),
  dbcache: Value.number({
    name: 'Database Cache (MB)',
    description: 'Memory allocated to the database cache. More cache = faster sync.',
    required: true,
    default: 512,
    min: 64,
    integer: true,
    units: 'MB',
  }),
  maxconnections: Value.number({
    name: 'Max Connections',
    description: 'Maximum number of peer connections.',
    required: true,
    default: 20,
    min: 1,
    integer: true,
  }),
})

export const config = sdk.Action.withInput(
  'config',
  async ({ effects }) => ({
    name: 'Configure',
    description: 'Adjust Bitcoin Cash Node settings',
    warning: 'Changing these settings requires restarting the node.',
    allowedStatuses: 'any',
    group: null,
    visibility: 'enabled',
  }),
  inputSpec,
  async ({ effects }) => ({
    prune: 0,
    dbcache: 512,
    maxconnections: 20,
  }),
  async ({ effects, input }) => {
    // Settings are noted — node must be restarted for changes to take effect
  },
)
