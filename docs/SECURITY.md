# Security

## No secrets in the repository

This script deliberately stores no API keys, tokens, cookies, or credentials. All credentials are read at runtime.

Router key lookup order:

1. `--api-key <key>`
2. `ROUTER_API_KEY`
3. SQL query from `--db-key-query` / `ROUTER_DB_KEY_QUERY` against the local SQLite DB

For upstream metadata, the script reads `apiKey` from provider connection rows in the same local DB. No key is written to `opencode.json`, the state file, logs, or `--json` output.

## Avoid

- Do not paste raw keys in issues, README files, or chat logs.
- Do not commit `opencode.json`, `.9router-sync-state.json`, or `*.bak-*` backups.
- Do not commit a limit-override file if its model IDs are sensitive in your setup.

## Rotation

If a key was ever exposed in chat, logs, or screenshots, rotate it in the provider dashboard. Then remove the old connection in 9router and add a new one.

## File permissions

Config writes use mode `0600` and atomic rename. Backups are also created with mode `0600`.

## Reporting issues

Include:

- `sync-9router-opencode --version`
- Node version
- 9router and OpenCode versions
- Output of `sync-9router-opencode --dry-run --json --show-context`

Never include API keys, cookies, or raw DB dumps.
