# Changelog

## 4.1.0

- Added upstream metadata checks for context windows via `GET {baseUrl}/models` for `openai-compatible` nodes.
- Limit precedence is now: override file → upstream metadata → 9router caps.
- Added `--show-context`, `--no-upstream-metadata`, `--upstream-timeout`, and `--db-nodes-query`.
- Added `limits.sources` to JSON output.
- Fixed `hy4-flash:free` from 200,000 to 1,048,576 tokens automatically.

## 4.0.0

- Rewrote the script with zero hardcoded providers, prefixes, aliases, or model IDs.
- Data sources: `/v1/models`, `/api/models`, `/api/provider-nodes`, `/api/models/availability`.
- Removed built-in provider special cases, name-based "free" heuristics, and 9router package-registry parsing.
- Provider IDs and names are restored from the existing config via a `prefix -> providerId` map.
- Added limit overrides, configurable endpoints, and configurable package/schema.
