# Security

## Credential sources

The tool never embeds secrets. The router key comes from:

1. `ROUTER_API_KEY`
2. the 9router SQLite database (`apiKeys` table, read-only)

Provider keys are read from `providerConnections` only to query upstream `/models` for context metadata. They are never printed, written to the repo, or included in `--json` output.

## What is written to disk

| File | Secrets? |
|---|---|
| `opencode.json` | Yes — router API key inside provider `settings`, as OpenCode requires |
| `.9router-sync-state.json` | No |
| `.9router-sync-cache.json` | No keys; fingerprints are truncated SHA-256 hashes |
| backups | Same contents as `opencode.json` |

All written files use mode `0600`, and writes are atomic (temp file + rename) so an interrupted run cannot leave a half-written config.

## Fingerprints

Probe and metadata cache entries are keyed by a truncated SHA-256 of router URL, provider key hash, model ID and capabilities. Rotating a key invalidates relevant cache entries without ever storing the key itself.

## SQLite access

- Read-only connection.
- Only two queries are used: the router key and provider connection keys.
- Both queries are overridable via `ROUTER_DB_KEY_QUERY` / `ROUTER_DB_NODES_QUERY` for unusual schemas.

## Backups

Every config change writes `opencode.json.bak-<timestamp>` with mode `0600`. Backups contain provider keys, so treat the config directory as sensitive and prune old backups.

## Reporting

Do not paste raw `--json` output publicly without checking it: it includes model IDs, error messages and provider names. It never includes API keys.
