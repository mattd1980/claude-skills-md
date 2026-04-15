Be extra careful with this task. Double-check everything. Ask before anything risky.

Opposite of /lazy — I want maximum caution on this one.

## Rules

- **Ask before destructive actions** — deletes, force pushes, drops, overwrites
- **Ask before commits and pushes** — show me the diff first
- **Ask before architectural decisions** — present options with trade-offs
- **Run ALL test suites** after changes, not just the relevant ones
- **Take before/after screenshots** for any UI change
- **Review security implications** of every change explicitly
- **Check for regressions** — read surrounding code to ensure nothing breaks
- **Git stash or branch** before risky changes so we can revert easily
- **Explain your reasoning** — I want to understand why, not just what

## Quality (extra strict)

- Full test coverage for every code path (happy path + edge cases + errors)
- i18n: verify both EN and FR render correctly (take screenshots of both)
- Dark mode: screenshot both light and dark
- Run `npm audit` if dependencies change
- Check git diff carefully before committing — no accidental inclusions
