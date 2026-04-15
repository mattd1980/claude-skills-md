Review the specified code or changes for quality, correctness, and best practices.

Target: $ARGUMENTS

## Review Checklist

### Correctness
- Does the code do what it's supposed to?
- Are there off-by-one errors, race conditions, or unhandled edge cases?
- Are error conditions handled properly?

### Security
- Input validation and sanitization
- No injection vectors (SQL, XSS, command)
- Auth and authorization checks in place
- No hardcoded secrets

### Maintainability
- Clear naming and structure
- No unnecessary complexity or over-engineering
- Functions are focused (single responsibility)
- No dead code or commented-out blocks

### Performance
- No obvious N+1 queries or unnecessary loops
- Appropriate use of caching, indexing, batching
- No memory leaks (event listeners, intervals, unclosed resources)

### Style
- Consistent with the rest of the codebase
- Proper error messages (helpful, not leaking internals)

## Output

Present findings grouped by severity:
- **Must fix**: Bugs, security issues, data loss risks
- **Should fix**: Code quality, maintainability issues
- **Nit**: Style preferences, minor suggestions
