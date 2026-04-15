Refactor the specified code for clarity, maintainability, and correctness.

Target: $ARGUMENTS

## Principles

- **Read first**: Understand the full file and its callers before changing anything
- **Minimal changes**: Only refactor what's needed — don't rewrite working code for style
- **No behavior changes**: Refactoring must not alter observable behavior
- **No over-engineering**: Don't add abstractions for one-time operations
- **Preserve tests**: All existing tests must still pass after refactoring

## Steps

1. Read the target file(s) and understand the current structure
2. Identify specific issues: duplication, unclear naming, deep nesting, long functions, mixed concerns
3. Plan the refactoring — describe what changes and why
4. Implement changes incrementally
5. Run existing tests to verify nothing broke
6. If the refactoring is large, present a before/after summary
