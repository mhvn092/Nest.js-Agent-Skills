# Stateless Architecture

Design replicated Kubernetes services so any pod can be replaced without losing required business
state or changing correctness.

## Required Rules

- Do not store shared or durable business state in process globals, singleton properties, arrays,
  maps, or sets.
- Do not rely on pod IPs or stable pod identity unless the workload is intentionally stateful.
- Do not save user uploads only to the container filesystem.
- Do not use an in-memory session store in replicated production services.
- Do not use an in-memory queue for work that must survive restart or coordinate across replicas.

In-memory data is allowed for bounded, disposable, correctness-independent purposes such as metrics,
short-lived request-local state, or caches where misses and resets are safe. Document the reason.

## Files

Stream durable uploads to object storage. Memory-buffered uploads are `CONDITIONAL`: they are safe
only with strict file-size limits and acceptable memory pressure. Prefer streaming for large files.

Local ephemeral storage is acceptable only for disposable scratch data with bounded size and cleanup.

## Scheduled Work

Treat non-idempotent `@Cron` jobs on replicated pods as unsafe.

Choose one:

- Make the operation idempotent and use a proven distributed lock.
- Move scheduling to a Kubernetes CronJob or dedicated scheduler.
- Use a durable queue with appropriate uniqueness and retry semantics.

Do not assume a Redis lock alone guarantees correctness. Account for lock expiry, retries, fencing,
and operation idempotency.

## WebSockets

When WebSocket connections span multiple replicas, use a compatible shared adapter or message
backplane. Verify sticky-session requirements for the selected transport and ingress.

## Authentication

Use verifiable tokens or a centralized session store. JWT verification is stateless only when
revocation, rotation, and authorization requirements do not depend on pod-local state.

## Migration Review

Search for:

```text
@Cron
@WebSocketGateway
diskStorage
fs.createWriteStream
fs.writeFile
express-session
new Map
new Set
globalThis
```

Classify each match by whether it affects correctness across replicas. Do not flag request-local or
disposable in-memory values as violations without tracing their use.
