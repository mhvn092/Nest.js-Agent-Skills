# Project Instructions for <PROJECT_NAME>

Single source of truth for coding agents (Codex, Claude Code, Antigravity / Gemini). `CLAUDE.md` and `GEMINI.md` only import this file; edit rules here.

## Overview

<Describe service purpose, transport (HTTP / microservice / worker), database/ORM, and external integrations.>

- **Layout:** `src/modules/` (features), `src/common/` or `src/shared/` (cross-cutting), `src/health/` (`/health`, `/ready`), `test/` (integration/e2e).
- **Commands:** Check `package.json` scripts (`lint`, `typecheck`, `test`, `test:e2e`, `build`). Run the narrowest target while iterating, and full verification once before finishing.

## Tool & MCP Policy (Strict Opt-In)

- **Never call MCP tools** (`call_mcp_tool`, `list_resources`, `read_resource`), inspect MCP schemas, or query external MCP servers (Jira, Confluence, MongoDB, MySQL, Redis, SonarQube, etc.) **unless the user explicitly names/requests that MCP tool or server in the current prompt**.
- Use local workspace files, `git`, and local CLI tools by default.

## Token & Context Hygiene

- Search with `rg`/`grep` before reading files; read targeted line ranges instead of whole large files.
- Never inspect `node_modules`, `dist`, `build`, `coverage`, maps, generated API specs (unless regenerating/verifying them), lockfiles (except version checks), or `.env` files.
- Never log secrets, credentials, tokens, authorization headers, cookies, or raw connection URIs.
- Do not duplicate helpers or leave unused parameters/exports/type-aliases; verify with `tsc --noEmit` (plus project dead-code/dup checks if configured).

## Skill Routing (Load Only What Matches)

Load **only** the skill(s) for the current task — never preload unrelated skills or read all reference/rule files upfront:

| Task | Skill(s) to Load | Notes |
| --- | --- | --- |
| NestJS modules, controllers, DTOs, guards, config, Swagger | `team-nestjs-engineering-standards` | Read only the needed `references/*.md`; load `nestjs-best-practices` only for general DI/lifecycle/perf rules |
| Drizzle ORM schemas, queries, transactions, migrations | `drizzle-best-practices` | Check `package.json` for `drizzle-orm` version (`0.45.x` vs `1.0.0-rc`); skip if not using Drizzle |
| PostgreSQL indexes, row locks (`FOR UPDATE`, `SKIP LOCKED`), triggers, SQL tuning | `supabase-postgres-best-practices` | Skip if not using Postgres |
| Branch, PR, or commit code review | `code-review` + `team-nestjs-engineering-standards` (`references/code-review-workflow.md`) | Single-pass review by default; sub-agents only if explicitly requested or diff > 15 files |
| Hard / flaky bugs or performance regressions | `diagnosing-bugs` | Skip full loop for trivial typos or obvious stack traces |
| Ultra-terse replies (`/caveman` or explicitly requested) | `caveman` | Do not load unless requested |

**Precedence on conflict:** User prompt -> Security & data integrity -> Existing public/DB contracts & `package.json` versions -> This `AGENTS.md` -> `team-nestjs-engineering-standards` -> `nestjs-best-practices` / domain skills.

## Engineering Rules

- **NestJS & TypeScript:** Inspect `package.json` and `tsconfig.json` before coding; never use `any`; keep changes scoped (`MIGRATION_TARGET` issues are reported, not refactored unasked).
  - `kebab-case` filenames; `_`-prefixed private members (for new/modified code); `[Entity][Operation][BriefDescription]Dto` naming.
  - Explicit role suffixes (`*.entity.ts`, `*.schema.ts`, `*.util.ts`, `*.mapper.ts`, `*.constants.ts`, `*.types.ts`, `*.schemas.ts`) and domain-qualified injected members (`_walletService`, `_databaseService` — never `_service`, `_db`, `_config`).
  - Strict separation of concerns: keep types, constants, schemas, utilities, mappers, and request/response DTOs in dedicated files rather than inside service/controller/guard/filter files.
  - Query-driven & covering indexes: audit indexes against real queries/constraints, drop unused ones, pair `INCLUDE (...)` covering indexes with narrow `SELECT` projections, and keep hot mutable columns out of `INCLUDE` to preserve HOT updates.
  - Decorator order: Routing -> Permission metadata -> Guards -> Interceptors/Pipes -> OpenAPI -> Status code.
  - Update Swagger/OpenAPI (`@nestjs/swagger`) in the same change as every HTTP contract change.
  - Throw NestJS `HttpException` / domain exceptions at HTTP boundaries (never bare `new Error()`).
  - Never use `@Optional()` on injected service/provider constructor params, or validation decorators on service/model constructors.
- **Testing:** Update tests to match changed logic (never weaken app logic for outdated tests); prefer realistic fixtures and property tests for math/boundaries when appropriate.
- **Git Commits:** `<type>(<scope>): <imperative summary < 72 chars>` (`<type>(*): ...` when > 10 files); types: `feat`, `fix`, `refactor`, `style`, `docs`, `test`, `chore`.

## Communication

- Keep responses concise, direct, and technically exact without filler or pleasantries.
- **Direction (LTR):** Keep Left-to-Right flow; when mixing Persian and English, put file paths, links, commands, and code on separate lines rather than inside Persian parentheses.
