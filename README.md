# Electrs Liquid for Umbrel

Electrum server for the Liquid Network, packaged as an Umbrel community app.

## Why?

Without your own Electrs server, your Liquid wallet queries Blockstream's public servers — leaking which addresses are yours. Even though Liquid hides amounts (Confidential Transactions), the transaction graph is still visible. Running your own server keeps all queries local.

## Architecture

```
Elements Core (Umbrel app)
        ↓ RPC
Electrs-Liquid (this app)
        ↓ Electrum protocol
Your wallet (Blockstream app, Ibis wallet, Bull wallet, Sideswap...)
```

## Requirements

### Electrs-Liquid (this app)
- **Disk:** ~65 GB for indexes
- **RAM:** 1-2 GB during normal operation
- `--lightmode` available to reduce disk usage by ~50% at the cost of slower lookups

### Elements Core (dependency, already installed on Umbrel)
- **Disk:** ~69 GB for the Liquid blockchain
- **RAM:** up to 6 GB (especially during initial block download with confidential proof verification)

### Total stack (Elements + Electrs-Liquid)
- **Disk:** ~134 GB
- **RAM:** 4-8 GB combined (during initial sync, lower after)
- **CPU:** any hardware capable of running Umbrel

> **Note:** These are conservative estimates. The Liquid chain is orders of magnitude smaller than Bitcoin mainnet, where Electrs indexes alone require 610+ GB. Exact figures will be confirmed after real-world testing.

## Docker Image

The Docker image is built via GitHub Actions and published to `ghcr.io/4rkad/electrs-liquid-umbrel`.

To trigger a build, push a version tag:

```bash
git tag v0.5.6
git push origin v0.5.6
```

Or trigger manually via the Actions tab.

## Installation on Umbrel

Install Electrs Liquid from the Umbrel community app store.

## Sync Status

Electrs Liquid needs to fully index the Liquid blockchain before your wallet can connect. This happens automatically but can take a few hours on first run.

### How to check progress

```bash
sudo docker logs -f 4rkad-electrs-liquid_electrs_1
```

### What you'll see in each stage

**1. Waiting for Elements to sync:**
```
WARN - waiting for bitcoind sync to finish: 847231/2500000 blocks, verification progress: 33.889%
```

**2. Downloading block headers:**
```
INFO - downloading all block headers (compact mode) up to <tip>
INFO - downloaded 100000/1900000 block headers (5%)
```

**3. Indexing transactions:**
```
INFO - adding txes from blocks 500/1900000 (0.0%)
```

**4. Fully synced (ready to use):**
```
INFO - Electrum RPC server running on 0.0.0.0:60601
```
After this, logs go quiet — one entry per new Liquid block (~1 min). Occasional `WARN reconnecting to bitcoind` messages are normal and do not affect operation.

## Connecting your wallet

Once running, connect your wallet's Electrum server setting to:

- **Local:** `your-umbrel-ip:60601`
- **Tor:** available via the Tor hidden service (shown in the Umbrel UI)

## Credits

- [Blockstream Electrs](https://github.com/Blockstream/electrs) — the Electrs fork with Liquid support
- [Umbrel](https://umbrel.com) — the platform
- [Elements Project](https://elementsproject.org) — Liquid Network implementation
