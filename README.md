# Agents Skills & NestJS Engineering Kit

Portable, offline-ready collection of **7 lean, non-conflicting engineering skills**, **`AGENTS.md` / `GEMINI.md` / `CLAUDE.md` templates**, and **cross-platform installers** for **Antigravity / Gemini**, **Codex**, and **Claude Code**.

Built for **NestJS** backend services (PostgreSQL / Drizzle, strict engineering standards, root-cause debugging, and single-pass code reviews) with **task-based skill routing** and **opt-in-only MCP rules** to minimize token usage.

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
├── skills/                    # 7 lean agent skills (SKILL.md + references)
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
| `--prune` | `-Prune` | Remove retired or excluded kit skills from the target directory |
| `--dry-run` | `-DryRun` | Preview planned copies without modifying disk |

**Global target paths (`--agents auto` vs `all`):**

| Target | Path | Default in `auto` |
| --- | --- | --- |
| `antigravity` / `gemini` | `~/.gemini/config/skills/` | Always |
| `agents` | `~/.agents/skills/` | Always |
| `claude` | `~/.claude/skills/` | If `~/.claude` exists |
| `codex` | `~/.codex/skills/` | If `~/.codex` exists |

---

## Included Skills (7 Lean Core)

### NestJS Architecture & Standards

| Skill | Purpose |
| --- | --- |
| `team-nestjs-engineering-standards` | **Team baseline & override**: coding style, `_`-prefixed privates, decorator order, DTO naming, Swagger/OpenAPI sync, config, K8s health probes, statelessness, and code-review workflow |
| `nestjs-best-practices` | General NestJS DI, lifecycle, security, and performance baseline (overridden by `team-nestjs-engineering-standards` on conflicts) |

### Database & Persistence

| Skill | Purpose |
| --- | --- |
| `drizzle-best-practices` | Drizzle ORM schemas, transactions, queries, and migrations (`0.45.x` and `1.0.0-rc`) |
| `supabase-postgres-best-practices` | PostgreSQL indexing, row locking (`FOR UPDATE`, `SKIP LOCKED`), triggers, constraints, and query plan tuning |

### Debugging, Review & Communication

| Skill | Purpose |
| --- | --- |
| `code-review` | Two-axis review (Standards + Spec); single-pass by default to save tokens, sub-agents only on large/requested diffs |
| `diagnosing-bugs` | Systematic root-cause debugging for hard/flaky bugs and performance regressions |
| `caveman` | Ultra-compressed, technically exact replies (loaded only when `/caveman` or brevity mode is requested) |

---

## Token Optimization Built In

- **Task-to-Skill Routing (`templates/AGENTS.md`):** Agents load only the skill(s) matching the active task instead of preloading every reference file.
- **Strict MCP Opt-In (`templates/AGENTS.md`):** Agents must not call MCP tools or inspect MCP servers unless explicitly requested by the user in the current prompt.
- **No Redundant Skills:** Conflicting/overlapping skills (`nestjs-modular-monolith`, `backend-development`, duplicate `nestjs-*` pack, `tdd`, `domain-modeling`, `codebase-design`, `graphify`) are removed.

## Skill Precedence

When rules conflict (defined in [templates/AGENTS.md](./templates/AGENTS.md) and [decision-policy.md](./skills/team-nestjs-engineering-standards/references/decision-policy.md)):

1. Explicit user request and acceptance criteria
2. Security, correctness, and data-integrity requirements
3. Existing public contracts, installed package versions, and deployment constraints
4. Project-local `AGENTS.md`
5. `team-nestjs-engineering-standards`
6. `nestjs-best-practices` and domain skills

---

## Further Guides

See [docs/GUIDE.md](./docs/GUIDE.md) for:
- How `AGENTS.md`, `GEMINI.md`, and `CLAUDE.md` discovery works (and the parent-folder vs service-folder workspace rule)
- Monorepo `.agents/skills.json` setup
- Customizing templates per stack (PostgreSQL/Drizzle vs MongoDB/Mongoose/TypeORM)
- Links to all `team-nestjs-engineering-standards` reference docs (code review, API contracts, K8s probes, statelessness, config)
