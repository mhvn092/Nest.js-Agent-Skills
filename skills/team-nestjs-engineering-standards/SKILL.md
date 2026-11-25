---
name: team-nestjs-engineering-standards
description: Team NestJS backend engineering and code-review standards for coding style, API contracts, distributed-system failures, configuration, Kubernetes health probes, and stateless architecture. Use when writing, reviewing, refactoring, or migrating NestJS services, pull requests, branches, or commits. Inspect versions, architecture, callers, consumers, failure paths, and compatibility before applying rules. Treat these team rules as overrides to generic NestJS best-practice skills.
---

# Team NestJS Engineering Standards

Apply these standards together with `nestjs-best-practices`. When rules conflict, follow [references/decision-policy.md](references/decision-policy.md). **Token rule:** read only the specific `references/*.md` file(s) needed for the current task.

## Required Workflow

1. Inspect the repository before proposing or making changes:
   - Read `package.json`, the lockfile, Nest CLI config, TypeScript config, and relevant modules.
   - Identify NestJS, Node.js, transport, database driver, ORM, and deployment versions.
   - Inspect existing conventions, generated code, tests, and deployment manifests.
2. Classify each applicable rule as:
   - `REQUIRED`: enforce for new and modified code.
   - `CONDITIONAL`: enforce only when its stated conditions are true.
   - `MIGRATION_TARGET`: report or plan separately unless the task explicitly includes migration.
3. Prefer compatibility with the project's supported package versions and established architecture.
4. Keep changes scoped. Do not perform repository-wide renames or migrations unless requested.
5. Explain material deviations from these standards and the reason for each deviation.
6. Verify changes using the project's existing lint, test, build, and validation commands.
7. Update and verify Swagger/OpenAPI in the same change as every HTTP API contract change.

For any code review, read and follow
[references/code-review-workflow.md](references/code-review-workflow.md) before reporting findings.

## References

- For precedence, applicability, and conflict resolution, read
  [references/decision-policy.md](references/decision-policy.md).
- For naming, structure, DTO, Swagger, errors, and controller rules, read
  [references/nestjs-coding-standards.md](references/nestjs-coding-standards.md).
- For environment variables and connection configuration, read
  [references/configuration-standards.md](references/configuration-standards.md).
- For Kubernetes health endpoints and probe behavior, read
  [references/kubernetes-health-probes.md](references/kubernetes-health-probes.md).
- For Kubernetes statelessness and scaling, read
  [references/stateless-architecture.md](references/stateless-architecture.md).
- For deep code review, failure analysis, concurrency, and maintainability, read
  [references/code-review-workflow.md](references/code-review-workflow.md).
- For API contracts, blast radius, and cross-team compatibility, read
  [references/api-contract-review.md](references/api-contract-review.md).
- For the required review report format, read
  [references/code-review-output.md](references/code-review-output.md).
- For installing and adopting this skill in team projects, read
  [references/team-adoption.md](references/team-adoption.md).

## Review Output

Lead with findings, ordered by severity. Prioritize correctness, security, data integrity, failure
behavior, API compatibility, and cross-service impact over style. Do not report speculative issues
without a reachable scenario and concrete impact.

Use [references/code-review-output.md](references/code-review-output.md) for the final structure.
