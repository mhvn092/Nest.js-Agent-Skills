# Agents Skills & NestJS Engineering Kit

Portable, offline-ready collection of **19 engineering skills**, **`AGENTS.md` / `GEMINI.md` / `CLAUDE.md` templates**, and **cross-platform installers** for **Antigravity / Gemini**, **Codex**, and **Claude Code**.

Built primarily for **NestJS** backend services (PostgreSQL / Drizzle, modular monoliths, financial/transactional systems, TDD, and structured code reviews), while remaining modular so you can exclude stack-specific skills per project.

---

## Repository Structure

```text
agents-skills/
├── README.md                  # Quick start & reference
├── docs/
│   └── GUIDE.md               # Detailed setup, workspace discovery, monorepo & review guides
├── install.sh                 # Linux / macOS installer (works from repo or zip)
├── install.ps1                # Windows PowerShell installer
├── nestjs-agent-kit.zip       # Single-file offline archive of skills, templates & installers
├── skills/                    # 19 agent skills (SKILL.md + references)
│   ├── team-nestjs-engineering-standards/
│   ├── nestjs-best-practices/
│   ├── ...
└── templates/                 # Single-source-of-truth instruction templates
    ├── AGENTS.md
    ├── GEMINI.md              # Imports AGENTS.md via @[AGENTS.md](./AGENTS.md)
    ├── CLAUDE.md              # Imports AGENTS.md via @AGENTS.md
    └── gitignore.snippet
```

---

## Quick Start

### 1. Clone on Linux / macOS

```bash
git clone git@github.com:mhvn092/agents-skills.git
cd agents-skills
```

**Install into a project (skills + `AGENTS.md` / `GEMINI.md` / `CLAUDE.md`):**

```bash
./install.sh --project /path/to/your-project
```

**Install globally for your user across coding agents:**

```bash
./install.sh --global --agents all
```

### 2. Clone on Windows (PowerShell)

```powershell
git clone git@github.com:mhvn092/agents-skills.git
cd agents-skills

# Project install
.\install.ps1 -Project C:\path\to\your-project

# Global install
.\install.ps1 -Global -Agents all
```

### 3. Offline / Air-Gapped Install (`nestjs-agent-kit.zip`)

Copy `nestjs-agent-kit.zip` (and optionally `install.sh`) to any machine, extract it, and run `./install.sh` (Linux/macOS) or `.\install.ps1` (Windows). `install.sh` also auto-detects `nestjs-agent-kit.zip` in the same directory even if you don't unzip it manually.

---

## Installer Options

| Flag (`install.sh`) | PowerShell (`install.ps1`) | Description |
| --- | --- | --- |
| `--project [DIR]` | `-Project DIR` | Install into `DIR/.agents/skills/` and copy rule templates (default mode) |
| `--global` | `-Global` | Install skills into user-global directories |
| `--agents LIST` | `-Agents LIST` | Global targets: `antigravity`, `agents`, `claude`, `codex`, `all`, or `auto` (default) |
| `--only LIST` | `-Only a,b` | Install only the listed skill names |
| `--exclude LIST` | `-Exclude a,b` | Skip specific skills (e.g. `--exclude drizzle-best-practices`) |
| `--no-rules` | `-NoRules` | Install skills only; skip `AGENTS.md` / `GEMINI.md` / `CLAUDE.md` |
| `--gitignore` | `-Gitignore` | Append AI tooling entries to target `.gitignore` if missing |
| `--force` | `-Force` | Overwrite existing `AGENTS.md` / `GEMINI.md` / `CLAUDE.md` |
| `--dry-run` | `-DryRun` | Preview planned copies without modifying disk |

**Global target paths (`--agents auto` vs `all`):**

| Target | Path | Default in `auto` |
| --- | --- | --- |
| `antigravity` / `gemini` | `~/.gemini/config/skills/` | Always |
| `agents` | `~/.agents/skills/` | Always |
| `claude` | `~/.claude/skills/` | If `~/.claude` exists |
| `codex` | `~/.codex/skills/` | If `~/.codex` exists |

---

## Included Skills (19)

### Team & NestJS Architecture

| Skill | Purpose |
| --- | --- |
| `team-nestjs-engineering-standards` | **Team override**: coding style, `_`-prefixed privates, decorator order, DTO naming, Swagger/OpenAPI sync, config, K8s health probes, statelessness, and code-review workflow |
| `nestjs-best-practices` | General NestJS architecture, DI, lifecycle, security, performance, and API design baseline |
| `nestjs` | Core NestJS CLI, module, and framework patterns |
| `nestjs-feature` | Vertical feature module scaffolding |
| `nestjs-modular-monolith` | Bounded contexts, module isolation, and shared vs domain boundaries |
| `nestjs-production` | Graceful shutdown, logging, health checks, and production readiness |
| `nestjs-auth` | Guards, authentication, authorization, and signature verification |
| `nestjs-data` | Repository and data-access patterns in NestJS |
| `nestjs-testing` | Unit, integration, and e2e testing with `@nestjs/testing` and `supertest` |

### Database & Persistence

| Skill | Purpose |
| --- | --- |
| `drizzle-best-practices` | Drizzle ORM schemas, transactions, parameterized queries, and migrations |
| `supabase-postgres-best-practices` | PostgreSQL indexing, row locking (`FOR UPDATE`, `SKIP LOCKED`), constraints, and performance |

### Domain Design, Testing, Debugging & Review

| Skill | Purpose |
| --- | --- |
| `backend-development` | Backend API, persistence, and service architecture guidance |
| `domain-modeling` | Rich domain types, state machines, and invalid-state prevention |
| `codebase-design` | Module boundaries, decoupling, and maintainable design |
| `tdd` | Test-driven development workflow |
| `code-review` | General code-review checklist (paired with `team-nestjs-engineering-standards` review guides) |
| `diagnosing-bugs` | Systematic root-cause debugging |

### Workflow & Communication

| Skill | Purpose |
| --- | --- |
| `caveman` | Ultra-compressed, technically exact agent responses |
| `graphify` | Persistent knowledge-graph codebase exploration (`graphify-out/`) |

---

## Skill Precedence

When rules conflict (defined in [templates/AGENTS.md](./templates/AGENTS.md) and [decision-policy.md](./skills/team-nestjs-engineering-standards/references/decision-policy.md)):

1. Explicit user request and acceptance criteria
2. Security, correctness, and data-integrity requirements
3. Existing public contracts, installed package versions, and deployment constraints
4. Project-local `AGENTS.md`
5. `team-nestjs-engineering-standards`
6. `nestjs-best-practices` and other domain skills
7. General framework conventions

---

## Further Guides

See [docs/GUIDE.md](./docs/GUIDE.md) for:
- How `AGENTS.md`, `GEMINI.md`, and `CLAUDE.md` discovery works (and the parent-folder vs service-folder workspace rule)
- Monorepo `.agents/skills.json` setup
- Customizing templates per stack (PostgreSQL/Drizzle vs MongoDB/Mongoose/TypeORM)
- Links to all `team-nestjs-engineering-standards` reference docs (code review, API contracts, K8s probes, statelessness, config)
