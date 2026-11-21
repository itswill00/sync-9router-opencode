# Configuration

## Default locations

| Item | Path |
|---|---|
| OpenCode config | `$XDG_CONFIG_HOME/opencode/opencode.json` or `~/.config/opencode/opencode.json` |
| Sync state | `<config dir>/.9router-sync-state.json` |
| Limit override | `<config dir>/.9router-sync-limits.json` |
| 9router DB | `~/.9router/db/data.sqlite` |

All of these can be changed with CLI flags or environment variables.

## Environment variables

| Variable | Purpose |
|---|---|
| `ROUTER_PORT` | Default 9router port, `20128` |
| `ROUTER_BASE_URL` | Full router URL |
| `ROUTER_API_KEY` | Router key, replaces DB lookup |
| `ROUTER_API_BASE` | Router API base without `/v1` |
| `ROUTER_DB_PATH` | SQLite DB path |
| `ROUTER_DB_KEY_QUERY` | SQL query for the router key |
| `ROUTER_DB_NODES_QUERY` | SQL query for provider connection keys |
| `ROUTER_UPSTREAM_TIMEOUT` | Upstream metadata timeout in seconds |
| `ROUTER_PROBE_TIMEOUT` | Live probe timeout in seconds |
| `ROUTER_PROBE_CONCURRENCY` | Parallel probe workers |
| `ROUTER_PROBE_MAX_TOKENS` | Output token budget for the probe |
| `ROUTER_MODELS_PATH` | Override `/v1/models` |
| `ROUTER_API_MODELS_PATH` | Override `/api/models` |
| `ROUTER_PROVIDER_NODES_PATH` | Override `/api/provider-nodes` |
| `ROUTER_AVAILABILITY_PATH` | Override `/api/models/availability` |
| `OPENCODE_COMPATIBLE_PACKAGE` | OpenCode provider package |
| `OPENCODE_SCHEMA` | Config `$schema` URL |

## Limit override

The override file is a JSON object keyed by the full router `modelID`:

```json
{
  "centai/hy4-flash:free": {
    "context": 1048576,
    "output": 64000
  }
}
```

Both numbers are optional. Copy [`examples/limits.json`](../examples/limits.json) to the OpenCode config directory and rename it to `.9router-sync-limits.json`.

## Custom DB queries

Default router-key query:

```sql
SELECT key FROM apiKeys WHERE isActive = 1 ORDER BY createdAt ASC LIMIT 1
```

Default provider-connection query:

```sql
SELECT provider, data FROM providerConnections WHERE isActive = 1
```

The `data` column is expected to be JSON containing `apiKey`, `key`, `token`, or `accessToken`.

## Backups

Before the first write, the script creates:

```text
opencode.json.bak-YYYYMMDD-HHMMSS
```

Disable this with `--no-backup`.
