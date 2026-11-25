---
name: code-review
description: "Two-axis review of changes since a fixed point (commit, branch, tag, or merge-base): Standards (repo coding & engineering standards) and Spec (requirements/spec match). Use when reviewing a branch, PR, or work-in-progress diff."
---

Two-axis review of the diff between `HEAD` and a fixed point:

- **Standards**: does the code conform to the repo's documented standards (including `team-nestjs-engineering-standards` when present)?
- **Spec**: does the code faithfully implement the originating spec/requirements?

**Execution mode (token efficiency):**
- **Default (single pass):** Perform both axes in one pass for normal/small diffs (<= 15 changed files) to avoid multiplying prompt/context tokens.
- **Parallel sub-agents (opt-in / large diffs):** Only spawn two parallel sub-agents when the user explicitly requests parallel review or the diff exceeds ~15 files / 800 lines. When reviewing NestJS code, follow `team-nestjs-engineering-standards/references/code-review-workflow.md` and `code-review-output.md`.

## Process

### 1. Pin the fixed point

Use the fixed point the user supplied (commit SHA, branch, tag, `main`, `HEAD~5`, etc.); if omitted, ask or default to `main` / `HEAD` (for unstaged/staged WIP) only if unambiguous.

Confirm the ref resolves (`git rev-parse <fixed-point>`) and inspect `git log <fixed-point>..HEAD --oneline` and `git diff --stat <fixed-point>...HEAD` before reading individual hunks.

### 2. Identify the spec source

Check in order:
1. A spec path or requirement supplied by the user.
2. Relevant spec files under `docs/`, `specs/`, or `README.md`.
3. Issue references in commit messages (do **not** invoke external MCP trackers unless the user explicitly asked).
4. If no spec exists, skip the Spec axis and note "no spec available".

### 3. Identify the standards sources

Check `AGENTS.md`, `CODING_STANDARDS.md`, `CONTRIBUTING.md`, and `team-nestjs-engineering-standards` (if installed).

On top of repo-documented rules, apply the **smell baseline** below (Fowler, _Refactoring_ ch.3). **Repo standards always override** the baseline, and skip anything already enforced by linters/typecheckers:

Each smell reads *what it is* → *how to fix*; match it against the diff:

- **Mysterious Name**: a function, variable, or type whose name doesn't reveal what it does or holds. → rename it; if no honest name comes, the design's murky.
- **Duplicated Code**: the same logic shape appears in more than one hunk or file in the change. → extract the shared shape, call it from both.
- **Feature Envy**: a method that reaches into another object's data more than its own. → move the method onto the data it envies.
- **Data Clumps**: the same few fields or params keep travelling together (a type wanting to be born). → bundle them into one type, pass that.
- **Primitive Obsession**: a primitive or string standing in for a domain concept that deserves its own type. → give the concept its own small type.
- **Repeated Switches**: the same `switch`/`if`-cascade on the same type recurs across the change. → replace with polymorphism, or one map both sites share.
- **Shotgun Surgery**: one logical change forces scattered edits across many files in the diff. → gather what changes together into one module.
- **Divergent Change**: one file or module is edited for several unrelated reasons. → split so each module changes for one reason.
- **Speculative Generality**: abstraction, parameters, or hooks added for needs the spec doesn't have. → delete it; inline back until a real need shows.
- **Message Chains**: long `a.b().c().d()` navigation the caller shouldn't depend on. → hide the walk behind one method on the first object.
- **Middle Man**: a class or function that mostly just delegates onward. → cut it, call the real target direct.
- **Refused Bequest**: a subclass or implementer that ignores or overrides most of what it inherits. → drop the inheritance, use composition.

### 4. Execute review (single pass or parallel sub-agents)

- **Single pass (default):** Inspect only the changed files and their immediate callers/contracts, then emit `## Standards` and `## Spec` directly.
- **Parallel sub-agents (when explicitly requested or large diff >15 files):** Spawn both sub-agents in parallel with:
  - **Standards sub-agent:** diff ref + commit list + standards sources + smell baseline (<400 words).
  - **Spec sub-agent:** diff ref + commit list + spec path/contents (<400 words).

### 5. Aggregate

Present the two reports under `## Standards` and `## Spec` headings, verbatim or lightly cleaned. Do **not** merge or rerank findings, because the two axes are deliberately separate (see _Why two axes_).

End with a one-line summary: total findings per axis, and the worst issue _within each axis_ (if any). Don't pick a single winner across axes: that's the reranking the separation exists to prevent.

## Why two axes

A change can pass one axis and fail the other:

- Code that follows every standard but implements the wrong thing → **Standards pass, Spec fail.**
- Code that does exactly what the issue asked but breaks the project's conventions → **Spec pass, Standards fail.**

Reporting them separately stops one axis from masking the other.
