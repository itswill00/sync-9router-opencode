# Changelog

## 4.2.1

- Added `--probe-skip` to trust already-verified providers without spending another probe request.
- Probe summary now reports the number of trusted (skipped) models.

dded a live response probe. By default, only models that return a non-empty chat response are written.
- Dropped models are reported in JSON (`probe.details`) and with `--show-dropped` in text output.
- Added `--no-probe`, `--probe-timeout`, `--probe-concurrency`, and `--probe-max-tokens`.
- A short second attempt with a larger token budget is used for empty reasoning responses and transient errors.

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
