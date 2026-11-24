# Decision Policy

Use this policy before applying any standard.

## Precedence

Apply rules in this order:

1. Explicit user request and acceptance criteria
2. Security, correctness, and data-integrity requirements
3. Existing public contracts, supported runtime versions, and deployment constraints
4. Project-local `AGENTS.md` rules
5. This team skill
6. Generic `nestjs-best-practices`
7. General framework conventions

Never silently violate a higher-priority rule to satisfy a lower-priority style rule.

## Rule Classes

### REQUIRED

Apply to all new and modified code unless a higher-priority constraint prevents it.

Examples:

- Never hardcode credentials.
- Never use `any` in authored application code.
- Prefix new or modified private members with `_`.
- Never log connection URIs or secrets.

### CONDITIONAL

Apply only after verifying the condition.

Examples:

- Require TLS connection schemes only when the backing service endpoint supports or requires TLS.
- Include a dependency in readiness only when losing it makes the pod unable to serve its intended
  traffic.
- Use disk health checks only when the service depends on writable local ephemeral storage.
- Use MongoDB SRV only when the deployed MongoDB topology publishes compatible SRV records.

### MIGRATION_TARGET

Use as the desired destination for legacy projects. Do not create broad unrelated changes.

Examples:

- Replace split connection variables with a single URI.
- Move local uploads to object storage.
- Rename existing private members.
- Replace existing nested barrel exports.
- Normalize legacy database table names.

## Compatibility Gate

Before using an API or library feature:

1. Determine the installed version from the lockfile, not from memory.
2. Check whether the API exists and is supported by that version.
3. Follow established project patterns when they are safe.
4. Avoid adding or upgrading dependencies unless needed for the requested work.
5. If a standard requires a migration, separate the compatibility change from the feature change
   where practical.

## Architecture Gate

Before applying a pattern, identify:

- HTTP-only, microservice-only, worker, or hybrid application
- Express or Fastify adapter
- ORM or database driver
- Existing configuration abstraction
- Deployment target and replica count
- Whether a dependency is critical, optional, or asynchronously consumed

Do not force an HTTP-controller pattern onto a transport-only service unless Kubernetes probes or
another explicit requirement justify a hybrid application.

## Scope Rule

Apply naming and formatting standards to files touched by the task. Report broader inconsistencies
as migration work instead of changing them opportunistically.
