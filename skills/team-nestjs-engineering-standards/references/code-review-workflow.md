# Code Review Workflow

Use this workflow for pull requests, branch diffs, commits, patches, and significant refactors.
Review the changed behavior, not only the changed lines.

## Review Objective

Find issues that can cause:

- Incorrect behavior, data loss, duplicate side effects, or security exposure
- Failures at system boundaries or under partial dependency failure
- Breaking API, event, database, configuration, or deployment contracts
- Race conditions, unsafe retries, and non-idempotent operations
- Avoidable coordination and rework with frontend, mobile, DevOps, QA, or other backend teams

Do not spend review attention on low-value style preferences while higher-risk behavior remains
unverified.

## Phase 1: Establish Scope And Intent

1. Identify the requested behavior and acceptance criteria.
2. Determine the review base and enumerate changed files.
3. Inspect relevant surrounding code, not only the diff.
4. Identify entry points, callers, consumers, persistence, external calls, and emitted outputs.
5. Read package versions, generated contracts, migrations, tests, and deployment configuration when
   relevant.
6. Separate intentional behavior changes from accidental changes.

If intent is unclear, state the assumption. Do not invent a defect solely from ambiguity.

## Phase 2: Trace Boundaries And Data Flow

Trace each meaningful changed path from source to sink:

```text
request/event/job
  -> validation and authorization
  -> domain decision
  -> database/cache/external side effects
  -> response/event/result
  -> downstream consumer behavior
```

At every boundary, check:

- Input validation, normalization, trust level, and type conversion
- Missing, empty, malformed, duplicate, stale, and oversized inputs
- Authorization and tenant or resource ownership
- Serialization, field naming, optionality, nullability, and defaults
- Timeout, retry, cancellation, and fallback behavior
- Partial success and compensation behavior
- Logging and observability without secret leakage

## Phase 3: Failure And Fallback Analysis

For every database, cache, broker, filesystem, and HTTP/RPC interaction, ask:

1. What happens on timeout?
2. What happens on explicit failure?
3. What happens when the dependency succeeds but the response is lost?
4. What happens when only part of the operation succeeds?
5. What happens during retry?
6. Is the fallback correct, stale-but-safe, fail-open, or fail-closed?
7. Does fallback hide a critical failure or corrupt state?
8. Can the caller distinguish retryable from permanent failure?

Reject fallback behavior that silently converts a security, payment, permission, or data-integrity
failure into success.

Validate cleanup paths such as transaction rollback, lock release, subscription cleanup, temporary
resource cleanup, and error mapping.

## Phase 4: Concurrency, Idempotency, And Ordering

Inspect read-modify-write flows, parallel requests, repeated messages, retries, cron jobs, queues,
and multi-replica execution.

Check for:

- Check-then-act race conditions
- Lost updates and last-write-wins surprises
- Duplicate inserts, payments, rewards, notifications, or external calls
- Missing unique constraints, atomic updates, transactions, or optimistic locking
- Lock expiry and unsafe distributed-lock assumptions
- Out-of-order, duplicated, or delayed events
- Acknowledging a message before durable completion
- Retrying non-idempotent operations without an idempotency key or deduplication strategy
- Side effects inside transactions that cannot be rolled back

Require idempotency where an operation can be retried by clients, brokers, infrastructure, or
operators. Prefer database-enforced invariants over process-local checks.

## Phase 5: API And Contract Impact

Read [api-contract-review.md](api-contract-review.md) whenever the change touches:

- Controllers, DTOs, Swagger/OpenAPI, generated clients, or public response models
- RPC patterns, events, message payloads, topics, queues, or headers
- Database schemas consumed by another service
- Environment variables, ports, health endpoints, or deployment manifests

For every HTTP contract change, require the Swagger/OpenAPI contract to be updated in the same
change and verify it matches runtime behavior. Treat missing or stale OpenAPI as a contract defect,
not a documentation preference.

## Phase 6: Security Review

Trace authorization from entry point to protected resource. Check:

- Authentication and authorization bypasses
- Resource ownership, tenant isolation, and object-level authorization
- Injection, unsafe deserialization, SSRF, path traversal, and mass assignment
- Secret, token, private-field, or sensitive-log exposure
- Insecure direct object references
- Rate-limit or abuse-control regressions
- Fail-open behavior
- Cryptographic misuse

Distinguish a reachable vulnerability from generic hardening advice.

## Phase 7: Design And Maintainability

Review SOLID, DRY, clean code, and design patterns as tools, not goals by themselves.

Report a design issue only when it creates concrete risk such as:

- Multiple responsibilities make failure handling inconsistent.
- Duplication can cause contract or security behavior to diverge.
- Tight coupling makes a required change unsafe across services.
- A dependency cannot be isolated or tested.
- An abstraction leaks transport or persistence details into domain behavior.

Suggest a design pattern only when it solves a demonstrated problem. Name the tradeoff and avoid
introducing abstraction for hypothetical future use.

## Phase 8: TypeScript Type Safety

Check both compile-time and runtime safety:

- No authored `any`, unsafe casts, or unchecked non-null assertions
- External inputs validated at runtime before trusted typing
- Discriminated unions handled exhaustively
- Optional and nullable fields handled deliberately
- Generic constraints preserve useful types
- Error values narrowed from `unknown`
- DTO, entity, response, and generated-client types remain aligned
- No false safety from casting parsed JSON or unvalidated configuration

Do not treat TypeScript types as runtime validation.

## Phase 9: Tests And Verification

Map tests to changed risks, not merely changed functions.

Expect focused tests for:

- Happy path
- Boundary and invalid inputs
- Dependency timeout and failure
- Retry and duplicate execution
- Parallel execution or atomicity where relevant
- Authorization failures
- Backward-compatible and legacy inputs
- Contract serialization and response shape
- Swagger/OpenAPI generation or schema verification for changed HTTP contracts

Run the narrowest relevant tests first, then broader checks according to blast radius. If a risk
cannot be tested locally, state the remaining verification gap.

## Finding Quality Gate

Report a finding only when all are present:

1. A reachable scenario
2. The incorrect or risky behavior
3. Concrete impact
4. Evidence in code or contract
5. A practical remediation direction

Do not report:

- Pure preference without team-rule violation or behavioral impact
- Hypothetical issues requiring unsupported assumptions
- Existing unrelated problems outside review scope, except critical security or data-loss risks
- Duplicate findings with the same root cause
