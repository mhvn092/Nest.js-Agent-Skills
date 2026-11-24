# API And Contract Review

Use this review for HTTP APIs, RPC handlers, events, queues, generated clients, configuration
contracts, and database schemas shared across service boundaries.

## Contract Inventory

Before approving a contract change, identify:

- Producers and consumers
- Synchronous callers and asynchronous subscribers
- Frontend, mobile, admin, partner, and internal-service clients
- Generated OpenAPI clients and their generation source
- API gateway, proxy, validation, caching, and authorization behavior
- Deployment order and whether old and new versions coexist during rollout

Search the repository and available related repositories for endpoint paths, message patterns,
event names, DTO names, fields, and configuration keys.

## Swagger And OpenAPI Synchronization

Treat Swagger/OpenAPI as an executable, cross-team contract.

For every changed HTTP API, verify in the same change that:

- Route, HTTP method, parameters, queries, headers, request body, and content types are accurate.
- Request DTO validation and OpenAPI required, optional, nullable, enum, and default metadata agree.
- Success response DTOs, serialization, examples, status codes, and empty responses agree.
- Expected error status codes and response shapes are documented.
- Authentication, authorization, public access, and deprecation state are represented correctly.
- Shared DTO changes have not silently changed unrelated endpoints.
- Generated OpenAPI output and generated clients are updated or verified when the project uses them.

An API implementation change without its required Swagger/OpenAPI update is a reportable contract
defect. Mark the review `Changes required` when stale documentation can mislead consumers, generated
clients, QA, or another team.

Do not approve Swagger-only changes that document behavior the runtime does not implement.

## Blast-Radius Questions

For each changed contract, ask:

1. Does removing, renaming, retyping, or making a field required break an existing consumer?
2. Does changing `null`, omission, empty arrays, defaults, status codes, or error shapes change
   consumer behavior?
3. Does changing pagination, sorting, filtering, date format, timezone, or identifier format break
   assumptions?
4. Does the generated client need regeneration?
5. Do validators, Swagger schemas, implementation types, and runtime responses agree?
6. Does another endpoint reuse the changed DTO, entity, mapper, serializer, or shared service?
7. Does a database migration preserve compatibility during rolling deployment?
8. Can old producers communicate with new consumers and new producers with old consumers?
9. Does cache content or key format require versioning or invalidation?
10. Does deployment require coordination with another team?
11. Was Swagger/OpenAPI updated, generated, and checked against the actual runtime contract?

## Backward Compatibility

Prefer additive changes:

- Add optional response fields.
- Accept both old and new input forms during a defined migration window.
- Introduce a new event version or endpoint version for incompatible changes.
- Use expand-and-contract database migrations.
- Preserve old configuration keys temporarily only when a controlled deprecation path exists.

Treat these as potentially breaking:

- Removing or renaming fields
- Changing field type, meaning, units, enum values, or validation rules
- Making optional input required
- Changing default behavior
- Reusing an event name with incompatible payload semantics
- Changing error codes or retryability
- Returning private data that was previously omitted

Document the deprecation and removal plan. Do not create indefinite dual behavior without ownership.

## Distributed Contract Behavior

For RPC and events, review:

- Timeout budget and error mapping
- Delivery semantics and duplicate handling
- Correlation and idempotency keys
- Schema versioning
- Consumer behavior for unknown fields and enum values
- Poison-message behavior and dead-letter handling
- Acknowledgment timing
- Ordering assumptions

Never assume exactly-once delivery unless the complete infrastructure and business operation provide
that guarantee.

## Cross-Team Handoff

To reduce back-and-forth, require the change description to state when relevant:

- Contract before and after
- Affected consumers and owners
- Required generated-client updates
- Swagger/OpenAPI before and after, including any generated document or client changes
- Migration and rollout order
- Compatibility window and removal date
- Feature flag or rollback strategy
- New environment variables, secrets, ports, permissions, or infrastructure
- Test evidence and unresolved integration risks

Flag missing handoff information when another team must act for the change to work safely.
