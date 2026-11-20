# Architecture

## Data flow

```text
9router /v1/models --------------> routable catalog (source of truth)
9router /api/models -------------> names, capabilities, limits
9router /api/provider-nodes -----> prefix, baseUrl, node id
9router /api/models/availability -> connection health (optional)
provider {baseUrl}/models -------> upstream context window (optional)
local 9router DB ----------------> connection keys (runtime only)
                 |
                 v
        model objects: id, providerId, name, caps, limit, contextSource
                 |
                 v
        provider map -> merge or replace -> opencode.json
                 |
                 v
        .9router-sync-state.json + opencode reload
```

## No hardcoded identities

The script contains no provider list, prefix list, alias list, or model list. Names come from:

- `node.name` or `providerSpecificData.prefix` for custom nodes
- the existing `provider.name` for built-in providers
- `humanize(prefix)` as a last resort

Provider IDs are not guessed either. The script builds a `prefix -> providerId` map from `modelID` values already present in the config. This is why `oc` can stay `opencode` and `mmf` can stay `mimo-free` without any special case in code.

## Merge strategy

- `--replace`: `config.providers = generated`
- default:
  - remove previously managed providers that disappeared upstream, unless `--keep-missing`
  - merge old and new models
  - preserve other top-level keys such as `mcp`, `compaction`, `model`, and `$schema`
  - merge old and new `settings`

State is written to `.9router-sync-state.json` next to `opencode.json`.

## Limit resolution

For each model:

1. Read caps from `/api/models` and `/v1/models`.
2. If the node exposes upstream model metadata, use its context/output fields.
3. If `.9router-sync-limits.json` has an entry for the full `modelID`, that entry wins.
4. Write `limit.context` and `limit.output` into the OpenCode config.

The winning source is recorded in `contextSource` and aggregated in JSON as `limits.sources`.

## Filtering and safety

Filters are applied before provider construction. Models reported with a permanent upstream error by `/api/models/availability` are dropped and listed under `unavailable` in the summary.

All writes use an atomic temporary-file rename, with an optional backup before the first change.
