# sync-9router-opencode

Sync the **9router** model catalog into an **OpenCode** provider config — fast, safe, and only with models that actually answer.

Version **5.0.0** · Node.js 18+ · MIT

## Why

9router aggregates many providers behind one OpenAI-compatible endpoint. OpenCode needs an explicit provider/model map. Doing that by hand breaks constantly: new models never appear, dead models stay forever, context windows drift, and providers that start returning `402`/`404` keep showing up in the picker.

This tool keeps both sides aligned:

> Only models that 9router currently serves **and** that answer a live probe are written. Models already in your config are kept when a failure looks temporary (timeout, `429`, `5xx`) and dropped when it looks permanent (`402`, `404`, `410`, "model unavailable").

## Features

- **Zero hardcoded providers, prefixes, aliases, or model IDs.** Everything is discovered at runtime.
- **Cache-backed probing.** Results are reused for 12 hours, so routine runs take ~4 seconds instead of a minute.
- **Smart failure handling.** Permanent failures are removed; transient ones never nuke a working setup.
- **Adaptive rate limiting.** When a provider answers `429`, the probe slows that provider down instead of hammering it.
- **Upstream context verification.** `override → upstream /models → 9router` precedence, cached for 12 hours.
- **Filter-safe merging.** `--provider`/`--model` only touch what they match; other providers and stale entries are preserved.
- **Stable model keys and names.** Existing OpenCode keys/names are reused so your own edits are not overwritten.
- **Safe writes.** Atomic write, timestamped backup, and `opencode reload` only when the config actually changes.
- **No secrets in the repo.** The router key is read from env or the local SQLite DB at runtime.

## Install

```bash
git clone https://github.com/itswill00/sync-9router-opencode.git
cd sync-9router-opencode
make install                 # /usr/local/bin
make install PREFIX="$PREFIX" # Termux
```

## Usage

```bash
sync-9router-opencode                      # sync everything, with live probe
sync-9router-opencode --dry-run            # probe and report, write nothing
sync-9router-opencode --provider numes     # only that provider
sync-9router-opencode --refresh            # ignore caches, re-check everything
sync-9router-opencode --json               # full machine-readable report
```

That is the whole interface. Only ten flags exist, and six of them are rarely needed.

| Flag | Purpose |
|---|---|
| `-n, --dry-run` | Build and probe without writing |
| `--config <path>` | OpenCode config path |
| `--router <url>` | 9router URL (default `http://localhost:20128`) |
| `--provider <list>` | Limit to matching providers |
| `--model <glob>` | Limit to matching model IDs |
| `--no-probe` | Trust the catalog without testing |
| `--refresh` | Bypass caches for this run |
| `--json` | Machine-readable output |
| `--quiet` | Errors and warnings only |
| `--verbose` | Explain cache/probe/metadata decisions |

## How a run works

```text
9router /v1/models ─┐
/api/provider-nodes ├─► provider resolution ─► probe (cached) ─► merge ─► opencode.json
provider DB keys    ─┘                              ▲
                          probe cache ──────────────┘
```

1. Catalog and nodes are read from 9router.
2. Each catalog ID is mapped to an OpenCode provider ID using the existing config's `prefix → providerId` map, so your IDs (`oc`, `mmf`, …) stay stable.
3. Models are probed through the router. Success is cached; failures are classified as permanent or transient.
4. The config is merged per provider, preserving unmanaged providers, stable keys, custom names and settings.

## Failure classification

| Kind | Examples | Effect on an existing model |
|---|---|---|
| Permanent | `402` paid tier, `404`, `410`, "model unavailable", `ModelProtocolUnsupported` | Removed |
| Transient | timeout, `429`, `5xx`, empty response | Kept unchanged |
| New model that fails | any failure | Not added |

This is why a sync never leaves you with an empty provider after a bad day upstream.

## Context windows

| Priority | Source |
|---|---|
| 1 | `.9router-sync-limits.json` override |
| 2 | Upstream `GET {baseUrl}/models` |
| 3 | 9router caps |

Upstream lookups are cached per provider keyed by base URL + key hash, so a routine run does not re-download large catalogs. Context sources are always reported in `--json` under `limits`.

## Caches and state

| File | Contents |
|---|---|
| `.9router-sync-state.json` | Which providers this tool manages, plus prefixes |
| `.9router-sync-cache.json` | Probe results, upstream metadata, last catalog |
| `.9router-sync-limits.json` | Your context/output overrides |

Delete the cache file to force a cold probe, or use `--refresh` for a single run.

## Repository layout

```text
bin/sync-9router-opencode   # executable
docs/ARCHITECTURE.md        # data flow, merging, failure model
docs/CONFIG.md              # paths, env tuning, overrides
docs/SECURITY.md            # credential handling
examples/limits.json
CHANGELOG.md
```

## License

MIT — see [`LICENSE`](LICENSE).
