# Team Adoption

## Repository Naming

Use a neutral, organization-owned repository name:

```text
<organization>/team-nestjs-engineering-standards
```

Avoid personal names because the rules belong to the team and should remain maintainable when team
membership changes.

## Installation

Install the upstream general skill and the team override skill:

```bash
npx skills add Kadajett/agent-nestjs-skills --global
npx skills add <organization>/team-nestjs-engineering-standards --global
```

For reproducible team behavior, prefer project-scoped installation in each repository and commit the
agent skill configuration supported by the team's coding agents.

## Project AGENTS.md

Keep project-local instructions short and specific:

```markdown
# Project Agent Instructions

Use `nestjs-best-practices` as the general NestJS baseline.
Use `team-nestjs-engineering-standards` for implementation, deep code review, API compatibility,
failure analysis, team conventions, and Kubernetes decisions.

Project-local rules and existing public contracts override team defaults.
Inspect package versions and architecture before applying standards.
Do not perform broad migration work unless explicitly requested.
For reviews, trace changed behavior beyond the diff and prioritize boundary failures, race
conditions, idempotency, security, and backward compatibility.
Require Swagger/OpenAPI to be updated in the same change as every HTTP contract change.
```

Add only genuine project exceptions below that block, such as an existing naming convention,
transport constraint, or migration status.

## Updating

- Update upstream and team skills independently.
- Review changes before team-wide rollout.
- Test updated rules against at least one representative service.
- Version team-rule changes that alter generated code, deployment contracts, or review expectations.

## Recommended Review Request

Use a request that provides the review base and business intent:

```text
Review this branch against <base-branch> using team-nestjs-engineering-standards.
Prioritize boundary conditions, failure and fallback behavior, API blast radius, concurrency,
idempotency, security, backward compatibility, and cross-team rollout requirements.
Verify every changed HTTP API is accurately reflected in Swagger/OpenAPI.
Report findings first and do not make code changes.
```
