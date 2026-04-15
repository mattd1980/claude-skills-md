#!/usr/bin/env bash
# Sync skills and commands from this repo into ~/.claude/ via symlinks.
# Usage: ./scripts/sync.sh [--force] [--target <dir>]
set -euo pipefail

FORCE=0
TARGET="${HOME}/.claude"

while [[ $# -gt 0 ]]; do
    case "$1" in
        --force) FORCE=1; shift ;;
        --target) TARGET="$2"; shift 2 ;;
        *) echo "unknown arg: $1" >&2; exit 1 ;;
    esac
done

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SKILLS_SRC="${REPO_ROOT}/skills"
COMMANDS_SRC="${REPO_ROOT}/commands"
SKILLS_DST="${TARGET}/skills"
COMMANDS_DST="${TARGET}/commands"

mkdir -p "${SKILLS_DST}" "${COMMANDS_DST}"

link_one() {
    local src="$1" dst="$2" label="$3"
    local name
    name="$(basename "$src")"
    if [[ -e "$dst" || -L "$dst" ]]; then
        if [[ "$FORCE" -eq 1 ]]; then
            rm -rf "$dst"
        else
            echo "skip (exists):    $name"
            return
        fi
    fi
    ln -s "$src" "$dst"
    echo "linked $label:  $name"
}

echo "Syncing to $TARGET"
echo

for d in "${SKILLS_SRC}"/*/; do
    [[ -d "$d" ]] || continue
    name="$(basename "$d")"
    link_one "${d%/}" "${SKILLS_DST}/${name}" "skill"
done

for f in "${COMMANDS_SRC}"/*.md; do
    [[ -f "$f" ]] || continue
    name="$(basename "$f")"
    link_one "$f" "${COMMANDS_DST}/${name}" "command"
done

echo
echo "Done. Restart Claude Code to pick up new skills/commands."
