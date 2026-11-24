# Project Instructions for <PROJECT_NAME>

Single source of truth for coding agents (Codex, Claude Code, Antigravity / Gemini). `CLAUDE.md` and `GEMINI.md` only import this file; edit rules here.

## Overview

<Describe the service purpose, transport (HTTP / microservice / worker), database/ORM, and external integrations.>

- **Layout:**
  - `src/modules/` — domain feature modules
  - `src/shared/` or `src/common/` — cross-cutting config, errors, filters, guards, pipes, utils
  - `src/health/` — liveness and readiness probes (`/health`, `/ready`)
  - `test/` — integration and e2e tests
- **Commands:** Check `package.json` scripts first (typical: `npm run lint`, `npx tsc --noEmit`, `npm test`, `npm run test:e2e`, `npm run build`). Run the narrowest command that covers the change, and run full verification before finishing.

## Project Rules

- Inspect `package.json`, the lockfile, `nest-cli.json`, `tsconfig.json`, and existing modules before proposing or applying changes; keep changes scoped and never run broad unrequested migrations.
- Follow `team-nestjs-engineering-standards` for new and modified code:
  - kebab-case filenames; `_`-prefixed private members (treat renaming untouched legacy private members as a separate `MIGRATION_TARGET`).
  - Strict decorator order: Routing -> Permission metadata -> Guards -> Interceptors/Pipes -> OpenAPI decorators -> Status code.
  - `[Entity][Operation][BriefDescription]Dto` naming for new/modified DTOs.
  - Update Swagger/OpenAPI (`@nestjs/swagger`) in the same change as every HTTP contract change.
  - Throw NestJS `HttpException` / domain HTTP exceptions (or the project's RPC exception mapping for microservices) instead of bare `new Error()` in controller/boundary flows; preserve the centralized error response contract.
  - Never use `any` in authored application code.
- Never read `.env` files; never log secrets, credentials, tokens, authorization headers, cookies, or raw connection URIs.
- Do not inspect `node_modules`, `dist`, `build`, `coverage`, maps, or generated output. Read lockfiles only for dependency/version verification.

## Skills

Project skills live in `.agents/skills/` (or user-global skill directories). **Always load and follow the relevant skill(s) before designing, implementing, testing, or reviewing code:**

### Primary Engineering & NestJS Standards

- `team-nestjs-engineering-standards` — **Mandatory team baseline & override** for NestJS coding style, Swagger/OpenAPI contracts, configuration, Kubernetes health probes, statelessness, distributed-system failures, and findings-first code review.
- `nestjs-best-practices` — General NestJS architecture baseline (overridden wherever `team-nestjs-engineering-standards` or this file specifies otherwise).
- `nestjs`, `nestjs-feature`, `nestjs-modular-monolith`, `nestjs-production`, `nestjs-auth` — Module boundaries, feature scaffolding, production hardening, and auth/guard security.

### Database & Persistence (apply when matching the stack)

- `drizzle-best-practices` — Drizzle ORM schemas, transactions, and migrations (skip if the project does not use Drizzle).
- `supabase-postgres-best-practices` — PostgreSQL indexing, locking, constraints, and query performance (skip if not using PostgreSQL).
- `nestjs-data` — Data-access patterns within NestJS services.

### Domain Design, Testing, Debugging & Review

- `domain-modeling`, `codebase-design`, `backend-development` — Domain invariants, state machines, and API/module design.
- `tdd` & `nestjs-testing` — Unit, integration, and e2e testing.
- `code-review` — General review checklist, paired with `team-nestjs-engineering-standards` (`references/code-review-workflow.md` and `references/code-review-output.md`) for findings-first NestJS reviews.
- `diagnosing-bugs` — Systematic root-cause debugging for concurrency, database, and distributed failures.

### Communication & Architecture Graph

- `caveman` — Ultra-compressed, technically exact responses when brevity mode applies.
- `graphify` — Knowledge graph and architecture exploration when `graphify-out/` exists.

### Skill Precedence & Decision Policy

If rules or skills conflict, resolve in strict order (per `team-nestjs-engineering-standards/references/decision-policy.md`):

1. Explicit user request and acceptance criteria
2. Security, correctness, and data-integrity requirements
3. Existing public contracts, installed package versions, and deployment constraints
4. Project-local `AGENTS.md` (this file)
5. `team-nestjs-engineering-standards`
6. `nestjs-best-practices` and other domain skills
7. General framework conventions

Classify `team-nestjs-engineering-standards` rules as `REQUIRED` (new/modified code), `CONDITIONAL` (apply only when condition holds), or `MIGRATION_TARGET` (report/plan separately; do not refactor unrelated legacy code).

## Git & Commit Conventions

- **Format:** `<type>(<scope>): <short, imperative description>`
- **10+ files rule:** if a commit affects more than 10 files, use `<type>(*): <short, imperative description>`.
- **Types:** `feat`, `fix`, `refactor`, `style`, `docs`, `test`, `chore`
- **Rules:**
  - Lowercase type and scope; scope optional but recommended (module or file name).
  - Imperative tone (`add`, `fix`, `update` — not `added`, `fixed`).
  - Summary strictly under 72 characters.
  - Atomic commits: one logical change each; never commit broken builds or secrets.

## Testing Standards

- Tests follow implementation, never the reverse. When logic changes, update tests, mocks, and assertions to match; never weaken new application logic to satisfy an outdated legacy test.
- Prefer `@faker-js/faker` over hardcoded magic strings for IDs, identifiers, and timestamps when available/appropriate.
- Add `fast-check` property-based tests next to unit cases for validation, monetary math, boundaries, hashing, or state invariants when appropriate.

## No Duplicate or Dead Code

Before writing any helper, retry, hash, serializer, validator, DTO, or client:

- Search by behavior, not just name: query `graphify` when `graphify-out/` exists, then grep shared modules and the target module. Reuse or extend what exists.
- When replacing logic or renaming: delete the old version, its exports, alias types, imports, and tests in the same change. Never keep compatibility type aliases (`export type OldName = NewName;`).
- When extracting an interface, type, or helper out of a class file, export it only from the new file.
- Never use `@Optional()` on constructor parameters of services, repositories, or providers.
- Never place validation decorators (`@IsOptional()`, `@IsString()`, ...) on constructor parameters of domain models, entities, or services.
- Never leave an unused parameter or class member.
- Before calling a task done, check touched files:
  - `npx tsc --noEmit --noUnusedLocals --noUnusedParameters`
  - `npx -y knip@5 --reporter compact`
  - `npx -y jscpd@4 src --ignore "**/*.spec.ts" --min-lines 6`

## SonarQube Clean Code Guardrails

- **Cognitive complexity (`typescript:S3776`):** at most 15.
- **Max parameters (`typescript:S107`):** at most 7 per method.
- **Regex safety (`typescript:S5869`, `typescript:S6353`, `typescript:S6594`):** with `/i`, do not write redundant `[a-zA-Z]`; use `\d` instead of `[0-9]`; prefer `RegExp.exec()` over `match()`.
- **Node built-ins (`typescript:S7772`):** use the `node:` prefix (`node:crypto`, `node:path`, `node:fs`).
- **Imports & returns (`typescript:S3863`, `typescript:S3516`):** merge imports from the same module; use `void` instead of branches returning identical dummy values.
- **No hardcoded secrets (`secrets:S6697`):** none anywhere, including tests, mocks, and compose files.
- **Subprocess security (`javascript:S6890`):** in scripts use `process.execPath`, not bare `node`/`npx`.
- **Syntax:** no nested ternaries (`typescript:S3358`), use optional chaining (`typescript:S6582`), avoid redundant assignments (`typescript:S4165`), prefer `String.fromCodePoint()` (`typescript:S7758`) and `Number.parseFloat()` (`typescript:S7773`).
- **Docker hardening (`docker:S6471`, `docker:S6505`, `docker:S7031`):** `npm ci --ignore-scripts`, merge consecutive `RUN` instructions, and run production stages as non-root (`USER node` with `--chown=node:node`).

## Communication & Brevity

- Follow `caveman`: concise, direct responses that preserve technical accuracy without filler or pleasantries.
- **Direction (LTR):** keep Left-to-Right flow. When mixing Persian and English, never embed inline file links, identifiers, or English terms inside Persian sentences with parentheses. Put file paths, links, commands, and code on separate lines.
