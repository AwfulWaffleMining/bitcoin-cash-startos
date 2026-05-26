import { sdk } from './sdk'
import * as http from 'node:http'
import type { HealthCheckResult } from '@start9labs/start-sdk/package/lib/health/checkFns/HealthCheckResult'

// ── RPC helper ────────────────────────────────────────────────────────────────

function rpcCall(method: string): Promise<any> {
  return new Promise((resolve, reject) => {
    const body = JSON.stringify({
      jsonrpc: '1.0',
      id: 'healthcheck',
      method,
      params: [],
    })
    const req = http.request(
      {
        hostname: 'localhost',
        port: 9002,
        path: '/',
        method: 'POST',
        auth: 'bchuser:bchpass123',
        headers: {
          'Content-Type': 'application/json',
          'Content-Length': Buffer.byteLength(body),
        },
      },
      (res) => {
        let data = ''
        res.on('data', (chunk) => (data += chunk))
        res.on('end', () => {
          try {
            resolve(JSON.parse(data))
          } catch {
            reject(new Error('Invalid JSON response from RPC'))
          }
        })
      },
    )
    req.on('error', reject)
    req.setTimeout(5000, () => {
      req.destroy(new Error('RPC request timed out'))
    })
    req.write(body)
    req.end()
  })
}

// ── Main ──────────────────────────────────────────────────────────────────────

export const main = sdk.setupMain(async ({ effects }) => {
  console.info('Starting Bitcoin Cash Node...')

  return sdk.Daemons.of(effects)
    .addDaemon('bitcoind', {
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
        display: 'RPC',
        fn: () =>
          sdk.healthCheck.checkPortListening(effects, 9002, {
            successMessage: 'The Bitcoin Cash RPC interface is ready',
            errorMessage: 'The Bitcoin Cash RPC interface is not yet ready',
          }),
        gracePeriod: 60_000,
      },
      requires: [],
    })
    .addHealthCheck('sync', {
      ready: {
        display: 'Blockchain Sync',
        fn: async (): Promise<HealthCheckResult> => {
          try {
            const result = await rpcCall('getblockchaininfo')
            if (result.error) {
              return {
                result: 'failure',
                message: `RPC error: ${result.error.message}`,
              }
            }
            const progress: number = result.result?.verificationprogress ?? 0
            const blocks: number = result.result?.blocks ?? 0
            const headers: number = result.result?.headers ?? 0
            if (progress >= 0.9999) {
              return {
                result: 'success',
                message: 'Bitcoin Cash is fully synced',
              }
            }
            const pct = (progress * 100).toFixed(2)
            return {
              result: 'loading',
              message: `Syncing: ${pct}% (block ${blocks.toLocaleString()} of ~${headers.toLocaleString()})`,
            }
          } catch (e: any) {
            return {
              result: 'failure',
              message: `Cannot reach node: ${e.message}`,
            }
          }
        },
        gracePeriod: 120_000,
      },
      requires: ['bitcoind'],
    })
})
