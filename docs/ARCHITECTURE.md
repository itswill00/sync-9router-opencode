# Architecture

## Data flow

```text
9router
  GET /v1/models              routable catalog (id, caps, router limits)
  GET /api/provider-nodes      node id -> prefix, name, baseUrl
  SQLite providerConnections   node id -> upstream API key
  GET {node.baseUrl}/models    upstream context/output metadata

OpenCode
  opencode.json                providers -> models
  .9router-sync-state.json     managed provider ids + prefixes
  .9router-sync-cache.json     probe results, upstream metadata, catalog
  .9router-sync-limits.json    user overrides
```

Nothing provider-specific is compiled into the script. The only implied contract is 9router's own URL shape, and even those paths are overridable.

## Main phases

### 1. Discovery

`/v1/models` is the catalog. Every ID is `prefix/model`; the prefix identifies the 9router node. `/api/provider-nodes` and the provider-connection table are read once, in parallel, to resolve prefix → name/baseUrl/key.

### 2. Provider resolution

OpenCode provider IDs are *not* derived from 9router naming conventions, because real configs contain renamed providers (for example `oc` for OpenCode Free). Instead:

1. Build `prefix → providerId` from the models already present in `opencode.json`.
2. Fall back to the node prefix, then to a sanitized id.
3. If the resulting id would collide with an unmanaged provider, pick `<id>-router` (never overwrite user-owned providers).

This is what keeps `--provider` filters and existing customizations stable across runs.

### 3. Limits

For each model:

```text
context = override.context || upstream.context || router.context
output  = override.output  || upstream.output  || router.output
```

Upstream metadata is fetched per node, concurrency-limited, and cached with a fingerprint of `baseUrl + key hash`. A stale cache is still used if the node is temporarily unreachable, so a slow provider never causes context windows to collapse to the router's lower caps.

### 4. Probing

Each selected model gets a minimal chat request (`Reply exactly: PONG`).

- If the provider rejects the request shape (`temperature`, `max_tokens`), the probe retries with a minimal body.
- Reasoning models that hit `finish_reason=length` retry with a larger budget.
- `429`/`5xx`/timeouts retry once with a short delay.

Failures are classified:

| Class | Signal | Meaning |
|---|---|---|
| `permanent` | `400/402/403/404/410/413/422`, "not found", "unavailable", "insufficient", "free tier"… | Cannot work; safe to remove |
| `transient` | timeout, `429`, `5xx`, empty, network | Might work later; never remove an existing model |
| `ok` | non-empty content | Keep |

Probe results are cached per model with a fingerprint of router URL, provider key hash, model id and capabilities, so a key rotation or capability change invalidates the entry automatically.

### 5. Adaptive rate limiting

Probing 200+ models at once triggers provider rate limits, which would produce false "transient" results. The probe therefore enforces:

- a global semaphore (`ROUTER_PROBE_CONCURRENCY`, default 16);
- a per-provider limiter (default 3) that halves its concurrency and applies exponential cooldown when it sees `429`/rate-limit text;
- gradual recovery after successful requests.

## Merging

`--provider` and `--model` filters are applied *before* probing and again during merge:

- A provider not matched by `--provider` is never modified.
- A model not matched by `--model` is never removed.
- Managed providers missing from the catalog are kept when their 9router node still exists and not every remaining model failed permanently. This prevents a temporary node outage from deleting a provider.
- Unmanaged providers are never touched.

Merge result is written atomically with a timestamped backup. `opencode reload` runs only when the serialized config changed.

## State vs cache

- **State** is semantic: which providers this tool owns and their prefixes. It survives cache deletion.
- **Cache** is disposable: probe results, upstream metadata, and the last catalog. Deleting it only means slower next run.

If state is lost, managed providers are re-derived from `baseURL` matching the configured router.

## Why failures are split

A single "delete everything that fails" rule is catastrophic for real use:

- Providers rate-limit large probe batches.
- Some models are temporarily overloaded.
- Some setups have a local shim that is down for a minute.

Splitting permanent from transient keeps the catalog honest without destroying a working configuration.
