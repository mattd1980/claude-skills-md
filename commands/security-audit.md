Perform a security audit on the specified code.

Target: $ARGUMENTS

## Checklist

1. **Input validation**: All user-controllable input is validated and sanitized
2. **Injection**: No SQL injection, command injection, or template injection vectors
3. **XSS**: No `innerHTML` with unsanitized data; use `textContent` where possible
4. **Authentication**: All sensitive endpoints require auth; sessions are properly managed
5. **Authorization**: Users can only access their own resources; admin endpoints are protected
6. **Secrets**: No hardcoded API keys, passwords, tokens, or connection strings in code
7. **SSRF**: External URL fetches block internal/private IPs
8. **Path traversal**: File paths are validated with `realpath` or equivalent
9. **Rate limiting**: Public and sensitive endpoints have rate limits
10. **Dependencies**: Check for known vulnerabilities in dependencies (`npm audit`)
11. **Error handling**: Errors don't leak stack traces, internal paths, or sensitive info to users
12. **CORS/CSRF**: Cross-origin protections are in place

## Output

Present findings as a table:

| # | Severity | Issue | Location | Recommendation |
|---|----------|-------|----------|----------------|

Flag critical issues first. Include code snippets showing the vulnerability and the fix.
