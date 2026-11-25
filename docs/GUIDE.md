# Usage & Architecture Guides

This guide explains how to configure, customize, and get automatic skill/rule discovery across **Antigravity**, **Gemini CLI**, **Codex**, and **Claude Code**.

---

## 1. Single Source of Truth (`AGENTS.md` + `GEMINI.md` + `CLAUDE.md`)

Never duplicate project rules across multiple files. Maintain all instructions in `AGENTS.md` at your project root and keep thin import wrappers alongside it:

- **`GEMINI.md`** (Antigravity / Gemini):
  ```markdown
  <!-- Edit project instructions in AGENTS.md (single source of truth). -->
  @[AGENTS.md](./AGENTS.md)
  ```
- **`CLAUDE.md`** (Claude Code):
  ```markdown
  @AGENTS.md
  ```

Antigravity deduplicates resolved rule files automatically, so keeping `AGENTS.md` under **24,000 bytes** guarantees full inline loading without truncation.

---

## 2. How Automatic Discovery Works (Important Workspace Gotcha)

Coding agents discover `AGENTS.md`, `GEMINI.md`, and `.agents/skills/*/SKILL.md` by **walking UP** from your current workspace/working directory (CWD) to the repository root — **never down into subdirectories**.

### Single-Service Repo

If your service lives at `/workspace/my-service/`:
- Open `/workspace/my-service/` directly as your workspace.
- Antigravity / Codex / Claude automatically pick up `AGENTS.md`, `GEMINI.md`, and `.agents/skills/*/SKILL.md`.

### Parent Folder / Monorepo Workspace

If you open a parent folder `/workspace/` that contains `/workspace/service-a/.agents/skills/`:
- Starting a session in `/workspace/` will **not** auto-load `service-a/.agents/skills/` or `service-a/AGENTS.md`.
- **Two fixes:**
  1. **Recommended:** Open `/workspace/service-a/` directly when working on that service.
  2. **Monorepo / parent-folder config:** Create `/workspace/.agents/skills.json`:
     ```json
     {
       "entries": [
         { "path": "service-a/.agents/skills" }
       ]
     }
     ```
     Or install the skills globally on your machine via `./install.sh --global --agents all`.

---

## 3. Adapting to Different Stacks

The default template includes both NestJS skills and PostgreSQL/Drizzle skills. Customize per project:

- **MongoDB / Mongoose or TypeORM service:**
  ```bash
  ./install.sh --project /path/to/mongo-service --exclude drizzle-best-practices,supabase-postgres-best-practices --prune
  ```
  Then remove those two rows from the **Skill Routing** table in the project's `AGENTS.md`.
- **Upgrading an older install (remove retired skills):**
  ```bash
  ./install.sh --project /path/to/existing-service --prune
  ./install.sh --global --agents auto --prune
  ```
- **Keep AI files out of a shared team repo:**
  Pass `--gitignore` during `--project` install (uses `templates/gitignore.snippet`), or keep skills installed via `--global`.
- **Commit skills for team consistency:**
  Skip `--gitignore` and commit `.agents/skills/`, `AGENTS.md`, `GEMINI.md`, and `CLAUDE.md` directly to git.

---

## 4. Customizing `templates/AGENTS.md` After Install

After running `./install.sh --project <dir>`, edit `<dir>/AGENTS.md` and fill in:
1. `<PROJECT_NAME>` and **Overview** (transport: HTTP / NATS / RabbitMQ / gRPC; database/ORM; external integrations).
2. **Layout** and **Commands** (exact directories and `package.json` scripts).
3. **Project-Specific Rules** (financial invariants, auth guards, error response shapes, Swagger path).
4. **Skill Routing** & **Tool/MCP Policy** (remove unused DB rows; keep MCP opt-in-only unless explicitly needed).

---

## 5. `team-nestjs-engineering-standards` Reference Guides

All deep engineering standards live inside `skills/team-nestjs-engineering-standards/references/`:

| Guide | When to Read |
| --- | --- |
| [decision-policy.md](../skills/team-nestjs-engineering-standards/references/decision-policy.md) | Resolving rule conflicts; `REQUIRED` vs `CONDITIONAL` vs `MIGRATION_TARGET` classification |
| [nestjs-coding-standards.md](../skills/team-nestjs-engineering-standards/references/nestjs-coding-standards.md) | Naming, `_` private members, decorator order, DTOs, Swagger/OpenAPI, error handling |
| [configuration-standards.md](../skills/team-nestjs-engineering-standards/references/configuration-standards.md) | Environment variable validation, connection URIs, secret hygiene |
| [kubernetes-health-probes.md](../skills/team-nestjs-engineering-standards/references/kubernetes-health-probes.md) | `/health` liveness vs `/ready` readiness semantics and dependency checks |
| [stateless-architecture.md](../skills/team-nestjs-engineering-standards/references/stateless-architecture.md) | Multi-replica safety, avoiding in-memory state/locks, horizontal scaling |
| [code-review-workflow.md](../skills/team-nestjs-engineering-standards/references/code-review-workflow.md) | Deep code review tracing failure paths, concurrency, idempotency, and blast radius |
| [api-contract-review.md](../skills/team-nestjs-engineering-standards/references/api-contract-review.md) | Breaking-change detection, Swagger parity, and cross-service rollout checks |
| [code-review-output.md](../skills/team-nestjs-engineering-standards/references/code-review-output.md) | Findings-first severity-ordered review output format |
| [team-adoption.md](../skills/team-nestjs-engineering-standards/references/team-adoption.md) | Team rollout, review prompt template, and repo adoption patterns |

### Recommended Code Review Prompt

```text
Review this branch against main using team-nestjs-engineering-standards.
Prioritize boundary conditions, failure and fallback behavior, API blast radius, concurrency,
idempotency, security, backward compatibility, and cross-team rollout requirements.
Verify every changed HTTP API is accurately reflected in Swagger/OpenAPI.
Report findings first and do not make code changes.
```

---

## 6. Updating This Kit

If you add or update a skill inside `skills/`:
1. Regenerate `nestjs-agent-kit.zip` from the repository root so the offline bundle stays in sync:
   ```bash
   python3 -c '
   import os, zipfile
   root = "."
   include = ["README.md", "install.sh", "install.ps1", "skills", "templates", "docs"]
   with zipfile.ZipFile("nestjs-agent-kit.zip", "w", zipfile.ZIP_DEFLATED) as zf:
       for item in include:
           if os.path.isfile(item):
               zf.write(item, f"nestjs-agent-kit/{item}")
           elif os.path.isdir(item):
               for dirpath, _, filenames in os.walk(item):
                   for fn in filenames:
                       fp = os.path.join(dirpath, fn)
                       zf.write(fp, f"nestjs-agent-kit/{fp}")
   '
   ```
2. Commit and push to `origin main`.
