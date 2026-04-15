# claude-skills-md

Authoring source of truth for my reusable Claude Code skills and slash commands.
Edit here, sync into `~/.claude/` (and/or per-project `.claude/`) with the scripts in `scripts/`.

## Layout

```
skills/      # folder-per-skill (SKILL.md + supporting .md files)
commands/    # flat .md files, one per slash command
scripts/     # sync.ps1 / sync.sh — link this repo into ~/.claude/
```

## Skill format

Each skill is a directory containing at minimum a `SKILL.md` with YAML frontmatter:

```markdown
---
name: my-skill
description: When to trigger this skill. Be specific — this is how Claude decides relevance.
---

Skill body...
```

Supporting files (referenced from `SKILL.md`) live alongside it.

## Command format

Flat `.md` files in `commands/`. Filename becomes the slash command (`foo.md` → `/foo`).

## Sync

**Windows (PowerShell):**
```powershell
./scripts/sync.ps1
```
Creates directory junctions for skills and hard links for command files into `~/.claude/`.
No admin required. Edits in this repo appear immediately in `~/.claude/`.

**Unix (bash):**
```bash
./scripts/sync.sh
```
Uses symlinks.

## Adding a new skill

1. `mkdir skills/<name>` and create `SKILL.md` with frontmatter.
2. Run sync script (only needed once per new skill — existing ones stay linked).
3. Restart Claude Code session to pick it up.

## Adding a new command

1. Drop `commands/<name>.md` in place.
2. Run sync script.
