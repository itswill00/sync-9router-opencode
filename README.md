# sync-9router-opencode

A zero-hardcoded sync tool that turns the **9router** model catalog into an **OpenCode** provider config.

Version: **4.1.0** · Node.js 18+ · MIT license

## Purpose

9router exposes many chat providers through one OpenAI-compatible endpoint. OpenCode needs an explicit provider/model map before those models can be selected. Doing that map by hand is fragile: new models never appear, dead models stay forever, and context windows are often wrong because 9router can override upstream metadata.

This script keeps the two sides aligned:

> Only what 9router currently serves goes into OpenCode, and the context window is verified against the upstream provider.

## Features

- **Zero hardcoded providers, prefixes, aliases, or model IDs.** Every name comes from the running router.
- **Multiple sources of truth**
  - `GET /v1/models` — routable catalog
  - `GET /api/models` — display names, capabilities, limits
  - `GET /api/provider-nodes` — custom node prefix/baseUrl
  - `GET /api/models/availability` — optional health filtering
  - `GET {baseUrl}/models` — upstream context-window verification
- **Verified context window** — precedence: override file → upstream metadata → 9router caps.
- **No secrets in source** — API keys are read at runtime from flags, env vars, or the local SQLite DB.
- **Merge or replace** — `--replace` makes the config match the router exactly.
- **Atomic writes, optional backup, optional `opencode reload`.**
- **JSON output** with `--json` and `--show-context`.

## Install

```bash
git clone https://github.com/itswill00/sync-9router-opencode.git
cd sync-9router-opencode
make install
```

On Termux, set the prefix first:

```bash
make install PREFIX="$PREFIX"
```

The `install` target copies `bin/sync-9router-opencode` to `$PREFIX/bin/` with mode `0755`.

## Quick start

```bash
# Preview changes
sync-9router-opencode --dry-run

# Make OpenCode match 9router exactly
sync-9router-opencode --replace

# Show where every context window came from
sync-9router-opencode --dry-run --show-context

# Machine-readable output
sync-9router-opencode --json --show-context
```

Example `--show-context` output:

```text
centai/hy4-flash:free                       1048576 / out  64000  [upstream]
centai/deepseek-v4.1-flash                  1000000 / out 384000  [router]
```

## Context-window precedence

| Priority | Source | Controlled by |
|---|---|---|
| 1 | User override file | `.9router-sync-limits.json` |
| 2 | Upstream provider | `GET {baseUrl}/models` |
| 3 | 9router | `/api/models` + `/v1/models` |

Generic field names are recognized for context (`context_window`, `contextWindow`, `context_length`, `context`) and output (`max_output_tokens`, `maxOutputTokens`, `max_output`, `max_completion_tokens`).

See [`docs/CONFIG.md`](docs/CONFIG.md) for the override format.

## Important options

| Option | Description |
|---|---|
| `--router <url>` | 9router URL, default `http://localhost:20128` |
| `--config <path>` | Path to `opencode.json` |
| `--api-key <key>` | Router API key; otherwise read from DB |
| `--replace` | Replace the whole provider map |
| `--keep-missing` / `--prune-missing` | Keep or drop managed models missing upstream |
| `--provider <list>` / `--model <glob>` | Filters |
| `--no-upstream-metadata` | Skip upstream context verification |
| `--upstream-timeout <s>` | Upstream timeout, default 20 |
| `--show-context` | Print context window and its source |
| `--dry-run` | Do not write files |
| `--json` | Machine-readable summary |
| `--no-reload` | Do not run `opencode reload` |

Run `sync-9router-opencode --help` for the full list.

## Repository layout

```text
bin/sync-9router-opencode   # executable script
docs/ARCHITECTURE.md        # data flow and merge strategy
docs/CONFIG.md              # paths, env vars, limit overrides
docs/SECURITY.md            # credential handling
examples/limits.json        # sample context-window override
CHANGELOG.md
LICENSE
Makefile
package.json
```

## License

MIT — see [`LICENSE`](LICENSE).
