# Configuration

## Default locations

| Item | Path |
|---|---|
| OpenCode config | `$XDG_CONFIG_HOME/opencode/opencode.json` or `~/.config/opencode/opencode.json` |
| Sync state | `<config dir>/.9router-sync-state.json` |
| Sync cache | `<config dir>/.9router-sync-cache.json` |
| Limit overrides | `<config dir>/.9router-sync-limits.json` |
| 9router DB | `~/.9router/db/data.sqlite` |

## CLI flags

| Flag | Purpose |
|---|---|
| `-h, --help` | Help |
| `-v, --version` | Version |
| `-n, --dry-run` | Build and probe without writing |
| `--config <path>` | OpenCode config path (file or its directory) |
| `--router <url>` | 9router URL |
| `--provider <list>` | Only touch matching providers |
| `--model <glob>` | Only touch matching model IDs |
| `--no-probe` | Trust the catalog without live testing |
| `--refresh` | Ignore caches for this run |
| `--json` | Machine-readable report |
| `--quiet` | Errors and warnings only |
| `--verbose` | Explain decisions |

Tuning that almost nobody needs lives in the environment, not in flags.

## Environment variables

| Variable | Default | Purpose |
|---|---|---|
| `ROUTER_BASE_URL` | `http://localhost:20128` | Router base URL |
| `ROUTER_API_BASE` | derived | Router API base (without `/v1`) |
| `ROUTER_API_KEY` | from DB | Router key |
| `ROUTER_DB_PATH` | `~/.9router/db/data.sqlite` | SQLite path |
| `ROUTER_PROBE_TIMEOUT` | `10` | Per-request probe timeout (s) |
| `ROUTER_PROBE_CONCURRENCY` | `16` | Global probe workers |
| `ROUTER_PROBE_PER_PROVIDER` | `3` | Workers per provider |
| `ROUTER_PROBE_MAX_TOKENS` | `64` | Probe output budget |
| `ROUTER_PROBE_TTL` | `12` | Successful probe cache TTL (hours) |
| `ROUTER_FAIL_TTL` | `1` | Transient failure cache TTL (hours) |
| `ROUTER_METADATA_TTL` | `12` | Upstream metadata cache TTL (hours) |
| `ROUTER_UPSTREAM_TIMEOUT` | `8` | Upstream `/models` timeout (s) |
| `ROUTER_NO_UPSTREAM=1` | off | Skip upstream context lookups |
| `ROUTER_API_MODELS=1` | off | Use `/api/models` for display names/caps |
| `ROUTER_AVAILABILITY=1` | off | Use `/api/models/availability` |
| `ROUTER_NO_CACHE=1` | off | Disable probe/metadata cache |
| `ROUTER_NO_PROGRESS=1` | off | Disable progress line |
| `ROUTER_DEBUG=1` | off | Verbose logging |
| `OPENCODE_COMPATIBLE_PACKAGE` | `@opencode/ai/providers/openai-compatible` | Provider package |
| `OPENCODE_SCHEMA` | `https://opencode.ai/config.json` | Config `$schema` |

## Limit overrides

Keyed by the full router model ID, or nested by provider:

```json
{
  "centai/hy4-flash:free": { "context": 1048576, "output": 64000 },
  "fr": {
    "particle": { "context": 200000, "output": 64000 }
  }
}
```

Precedence: override → upstream metadata → 9router caps. Both numbers are optional.

## Cache behaviour

| Situation | Behaviour |
|---|---|
| Model probed OK | Reused for `ROUTER_PROBE_TTL` |
| Model failed permanently | Reused; never added |
| Model failed transiently | Reused for `ROUTER_FAIL_TTL`, existing model kept |
| Upstream metadata | Reused per node + key fingerprint |
| Router catalog unreachable | Last catalog used if under 1 hour old |

`--refresh` bypasses all of it. Deleting the cache file is equivalent and also drops entries for models that no longer exist.

## Exit behaviour

- Never writes when the merged config is unchanged.
- Never writes when zero models survive (unless `--no-probe` is used intentionally).
- Refuses to overwrite malformed JSON/JSONC.
- Refuses to overwrite an unmanaged provider on an ID collision.
