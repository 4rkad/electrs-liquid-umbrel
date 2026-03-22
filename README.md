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
Your wallet (Green, Ibis, Sparrow...)
```

## Requirements

### Electrs-Liquid (this app)
- **Disk:** 5-15 GB for indexes (Liquid has far fewer transactions than Bitcoin mainnet)
- **RAM:** 1-2 GB during normal operation
- `--lightmode` available to reduce disk usage by ~50% at the cost of slower lookups

### Elements Core (dependency, already installed on Umbrel)
- **Disk:** ~50 GB for the Liquid blockchain
- **RAM:** up to 6 GB (especially during initial block download with confidential proof verification)

### Total stack (Elements + Electrs-Liquid)
- **Disk:** ~55-65 GB
- **RAM:** 4-8 GB combined
- **CPU:** any hardware capable of running Umbrel

> **Note:** These are conservative estimates. The Liquid chain is orders of magnitude smaller than Bitcoin mainnet, where Electrs indexes alone require 610+ GB. Exact figures will be confirmed after real-world testing.

## Docker Image

The Docker image is built via GitHub Actions and published to `ghcr.io/4rkad/electrs-liquid-umbrel`.

To trigger a build, push a version tag:

```bash
git tag v0.4.1
git push origin v0.4.1
```

Or trigger manually via the Actions tab.

## Installation on Umbrel

Copy the `umbrel-app/` directory contents to your Umbrel's app directory:

```bash
# On your Umbrel
mkdir -p ~/umbrel/app-data/electrs-liquid
cp umbrel-app/* ~/umbrel/app-data/electrs-liquid/
```

Then restart Umbrel or install via the community app store.

## Connecting your wallet

Once running, connect your wallet's Electrum server setting to:

- **Local:** `your-umbrel-ip:60601`
- **Tor:** available via the Tor hidden service (shown in the Umbrel UI)

## Credits

- [Blockstream Electrs](https://github.com/Blockstream/electrs) — the Electrs fork with Liquid support
- [Umbrel](https://umbrel.com) — the platform
- [Elements Project](https://elementsproject.org) — Liquid Network implementation
