#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

MODE=""
PROJECT_DIR="."
GLOBAL_AGENTS="auto"
INSTALL_RULES=true
UPDATE_GITIGNORE=false
FORCE=false
DRY_RUN=false
ONLY_SKILLS=""
EXCLUDE_SKILLS=""
ZIP_PATH=""
TMP_DIR=""

usage() {
  cat <<'EOF'
NestJS Agent Kit Installer

Install bundled NestJS engineering skills and AGENTS.md / GEMINI.md / CLAUDE.md
templates into a project or user-global agent directories (offline-capable).

Usage:
  install.sh --project [DIR] [OPTIONS]
  install.sh --global [OPTIONS]

Modes:
  --project [DIR]      Install into DIR/.agents/skills/ and copy rule templates
                       (default: current directory if --global is not set)
  --global             Install skills globally into user agent directories

Options:
  --agents LIST        Comma-separated global targets: antigravity,agents,claude,codex,all,auto
                       (default: auto -> antigravity + agents, plus claude/codex if present)
  --zip PATH           Path to nestjs-agent-kit.zip (auto-detected next to script)
  --only LIST          Comma-separated skill names to install
  --exclude LIST       Comma-separated skill names to skip
  --no-rules           In --project mode, install skills only (skip AGENTS/GEMINI/CLAUDE.md)
  --gitignore          In --project mode, append AI tooling entries to .gitignore if missing
  --force              Overwrite existing AGENTS.md, GEMINI.md, CLAUDE.md in --project mode
  --dry-run            Show planned actions without writing files
  -h, --help           Show this help message

Examples:
  ./install-nestjs-agent-kit.sh --project ./my-nestjs-service
  ./install-nestjs-agent-kit.sh --project . --exclude drizzle-best-practices --gitignore
  ./install-nestjs-agent-kit.sh --global --agents all
EOF
}

cleanup() {
  if [ -n "$TMP_DIR" ] && [ -d "$TMP_DIR" ]; then
    rm -rf "$TMP_DIR"
  fi
}
trap cleanup EXIT

in_csv() {
  local needle="$1"
  local haystack="$2"
  local IFS=','
  local item
  for item in $haystack; do
    if [ "$item" = "$needle" ]; then
      return 0
    fi
  done
  return 1
}

should_install_skill() {
  local skill="$1"
  if [ -n "$ONLY_SKILLS" ] && ! in_csv "$skill" "$ONLY_SKILLS"; then
    return 1
  fi
  if [ -n "$EXCLUDE_SKILLS" ] && in_csv "$skill" "$EXCLUDE_SKILLS"; then
    return 1
  fi
  return 0
}

copy_skill_dir() {
  local src="$1"
  local dest_parent="$2"
  local name
  name="$(basename "$src")"
  local dest="$dest_parent/$name"

  if [ "$DRY_RUN" = true ]; then
    echo "  [dry-run] skill -> $dest"
    return 0
  fi

  mkdir -p "$dest_parent"
  rm -rf "$dest"
  mkdir -p "$dest"
  cp -R "$src/." "$dest/"
}

copy_template_file() {
  local src="$1"
  local dest="$2"
  local label
  label="$(basename "$dest")"

  if [ -e "$dest" ] && [ "$FORCE" != true ]; then
    echo "  [skip] $label already exists (use --force to overwrite)"
    return 0
  fi

  if [ "$DRY_RUN" = true ]; then
    echo "  [dry-run] template -> $dest"
    return 0
  fi

  cp "$src" "$dest"
  echo "  [ok] wrote $dest"
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --project)
      MODE="project"
      if [ "${2:-}" != "" ] && [[ "${2:-}" != -* ]]; then
        PROJECT_DIR="$2"
        shift 2
      else
        PROJECT_DIR="."
        shift
      fi
      ;;
    --global)
      MODE="global"
      shift
      ;;
    --agents)
      GLOBAL_AGENTS="${2:?--agents requires a value}"
      shift 2
      ;;
    --zip)
      ZIP_PATH="${2:?--zip requires a value}"
      shift 2
      ;;
    --only)
      ONLY_SKILLS="${2:?--only requires a value}"
      shift 2
      ;;
    --exclude)
      EXCLUDE_SKILLS="${2:?--exclude requires a value}"
      shift 2
      ;;
    --no-rules)
      INSTALL_RULES=false
      shift
      ;;
    --gitignore)
      UPDATE_GITIGNORE=true
      shift
      ;;
    --force)
      FORCE=true
      shift
      ;;
    --dry-run)
      DRY_RUN=true
      shift
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage >&2
      exit 1
      ;;
  esac
done

if [ -z "$MODE" ]; then
  MODE="project"
fi

KIT_ROOT=""
if [ -d "$SCRIPT_DIR/skills" ] && [ -d "$SCRIPT_DIR/templates" ]; then
  KIT_ROOT="$SCRIPT_DIR"
else
  if [ -z "$ZIP_PATH" ]; then
    if [ -f "$SCRIPT_DIR/nestjs-agent-kit.zip" ]; then
      ZIP_PATH="$SCRIPT_DIR/nestjs-agent-kit.zip"
    elif [ -f "./nestjs-agent-kit.zip" ]; then
      ZIP_PATH="./nestjs-agent-kit.zip"
    fi
  fi

  if [ -z "$ZIP_PATH" ] || [ ! -f "$ZIP_PATH" ]; then
    echo "Error: Could not find unpacked skills/templates or nestjs-agent-kit.zip." >&2
    echo "Pass --zip /path/to/nestjs-agent-kit.zip or run from the extracted kit folder." >&2
    exit 1
  fi

  TMP_DIR="$(mktemp -d)"
  if command -v unzip >/dev/null 2>&1; then
    unzip -q "$ZIP_PATH" -d "$TMP_DIR"
  elif command -v python3 >/dev/null 2>&1; then
    python3 -m zipfile -e "$ZIP_PATH" "$TMP_DIR"
  else
    echo "Error: unzip or python3 is required to extract $ZIP_PATH" >&2
    exit 1
  fi

  if [ -d "$TMP_DIR/nestjs-agent-kit/skills" ]; then
    KIT_ROOT="$TMP_DIR/nestjs-agent-kit"
  elif [ -d "$TMP_DIR/skills" ]; then
    KIT_ROOT="$TMP_DIR"
  else
    echo "Error: Invalid kit archive structure in $ZIP_PATH" >&2
    exit 1
  fi
fi

SELECTED_SKILLS=()
for skill_dir in "$KIT_ROOT"/skills/*; do
  [ -d "$skill_dir" ] || continue
  skill_name="$(basename "$skill_dir")"
  if should_install_skill "$skill_name"; then
    SELECTED_SKILLS+=("$skill_dir")
  fi
done

if [ "${#SELECTED_SKILLS[@]}" -eq 0 ]; then
  echo "No skills matched --only / --exclude filters." >&2
  exit 1
fi

if [ "$MODE" = "project" ]; then
  mkdir -p "$PROJECT_DIR"
  TARGET_DIR="$(cd "$PROJECT_DIR" && pwd)"
  SKILLS_DEST="$TARGET_DIR/.agents/skills"

  echo "Installing ${#SELECTED_SKILLS[@]} skills into $SKILLS_DEST ..."
  for skill_dir in "${SELECTED_SKILLS[@]}"; do
    copy_skill_dir "$skill_dir" "$SKILLS_DEST"
  done
  if [ "$DRY_RUN" != true ]; then
    echo "  [ok] installed ${#SELECTED_SKILLS[@]} skills"
  fi

  if [ "$INSTALL_RULES" = true ]; then
    echo "Installing rule templates into $TARGET_DIR ..."
    copy_template_file "$KIT_ROOT/templates/AGENTS.md" "$TARGET_DIR/AGENTS.md"
    copy_template_file "$KIT_ROOT/templates/GEMINI.md" "$TARGET_DIR/GEMINI.md"
    copy_template_file "$KIT_ROOT/templates/CLAUDE.md" "$TARGET_DIR/CLAUDE.md"
  fi

  if [ "$UPDATE_GITIGNORE" = true ]; then
    GITIGNORE_FILE="$TARGET_DIR/.gitignore"
    if [ -f "$GITIGNORE_FILE" ] && grep -qE '^\.agents/?$' "$GITIGNORE_FILE"; then
      echo "  [skip] .gitignore already ignores .agents/"
    elif [ "$DRY_RUN" = true ]; then
      echo "  [dry-run] append AI tooling ignore block to $GITIGNORE_FILE"
    else
      printf "\n" >> "$GITIGNORE_FILE"
      cat "$KIT_ROOT/templates/gitignore.snippet" >> "$GITIGNORE_FILE"
      echo "  [ok] updated $GITIGNORE_FILE"
    fi
  fi

  echo "Done. Open $TARGET_DIR as your workspace and customize AGENTS.md for project specifics."
else
  TARGET_DIRS=()
  add_target() {
    local d="$1"
    local existing
    for existing in "${TARGET_DIRS[@]:-}"; do
      if [ "$existing" = "$d" ]; then
        return 0
      fi
    done
    TARGET_DIRS+=("$d")
  }

  if [ "$GLOBAL_AGENTS" = "auto" ]; then
    add_target "$HOME/.gemini/config/skills"
    add_target "$HOME/.agents/skills"
    [ -d "$HOME/.claude" ] && add_target "$HOME/.claude/skills"
    [ -d "$HOME/.codex" ] && add_target "$HOME/.codex/skills"
  elif [ "$GLOBAL_AGENTS" = "all" ]; then
    add_target "$HOME/.gemini/config/skills"
    add_target "$HOME/.agents/skills"
    add_target "$HOME/.claude/skills"
    add_target "$HOME/.codex/skills"
  else
    IFS=',' read -r -a agent_list <<< "$GLOBAL_AGENTS"
    for agent in "${agent_list[@]}"; do
      case "$agent" in
        antigravity|gemini) add_target "$HOME/.gemini/config/skills" ;;
        agents) add_target "$HOME/.agents/skills" ;;
        claude) add_target "$HOME/.claude/skills" ;;
        codex) add_target "$HOME/.codex/skills" ;;
        *)
          echo "Error: Unknown agent target '$agent' (expected: antigravity, agents, claude, codex, all, auto)" >&2
          exit 1
          ;;
      esac
    done
  fi

  for dest_dir in "${TARGET_DIRS[@]}"; do
    echo "Installing ${#SELECTED_SKILLS[@]} skills into $dest_dir ..."
    for skill_dir in "${SELECTED_SKILLS[@]}"; do
      copy_skill_dir "$skill_dir" "$dest_dir"
    done
    if [ "$DRY_RUN" != true ]; then
      echo "  [ok] installed ${#SELECTED_SKILLS[@]} skills into $dest_dir"
    fi
  done

  echo "Done. Copy templates/AGENTS.md, templates/GEMINI.md, and templates/CLAUDE.md into any project root as needed."
fi
