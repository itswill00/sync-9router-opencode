# Changelog

## 5.0.0

Full rewrite. Faster, safer, and far fewer flags.

- **Cache-backed probing.** Successful probes are reused for 12 hours; a warm run now takes about 4 seconds instead of a minute.
- **Permanent vs transient failures.** `402`/`404`/`410`/"model unavailable"/"free tier" are removed. Timeouts, `429`, `5xx` and empty responses keep the existing model.
- **Adaptive rate limiting.** A provider that returns `429` is slowed down automatically instead of being flooded with parallel probes.
- **Filter-safe merging.** `--provider`/`--model` no longer delete unrelated providers or models.
- **Catalog fallback.** If the router is briefly unreachable, the last catalog (under 1 hour old) is used with a warning.
- **Duplicate-prefix safety.** Provider ID collisions no longer overwrite unmanaged providers.
- **Simpler interface.** Ten flags total; tuning moved to environment variables.
- **Better limits.** Upstream `/models` lookups are cached per node and key fingerprint; stale data is reused if a node is temporarily down.
- **Stable names and keys.** Existing OpenCode model keys and names are preserved across runs.
- **Quieter output.** Default output is a short, grouped summary; `--json` contains every detail.

### Removed

`--replace`, `--keep-missing`, `--prune-missing`, `--probe-skip`, `--show-dropped`, `--show-context`, `--no-backup`, `--no-reload`, `--min-models`, `--allow-empty`, `--package`, `--schema`, `--api-base`, `--api-key`, `--db`, `--db-key-query`, `--db-nodes-query`, `--models-path`, `--api-models-path`, `--provider-nodes-path`, `--availability-path`, `--no-upstream-metadata`, `--upstream-timeout`, `--probe-timeout`, `--probe-concurrency`, `--probe-max-tokens`, `--exclude`, `--exclude-model`, `--limit`, `--show-unavailable`, `--replace`.

Everything they controlled is still available via the environment variables documented in [`docs/CONFIG.md`](docs/CONFIG.md).

## 4.2.1

- Added `--probe-skip` to trust verified providers without another probe request.

## 4.2.0

- Added a live response probe; only models returning non-empty content are written.
- Added a second attempt with a larger token budget for reasoning models.

## 4.1.0

- Added upstream `/models` context checks with `override → upstream → router` precedence.
- Fixed `hy4-flash:free` context from 200,000 to 1,048,576.

## 4.0.0

- Rewrote the tool with zero hardcoded providers, prefixes, aliases, or model IDs.
- Provider IDs restored from the existing config through a prefix map.
