Write tests for the specified code.

Target: $ARGUMENTS

## Guidelines

- **Match the project's test framework** — check existing test files first
- **Test behavior, not implementation** — test what the code does, not how
- **Cover the happy path first**, then edge cases and error conditions
- **Use descriptive test names** that explain what's being verified
- **Keep tests independent** — no test should depend on another's state
- **Mock external dependencies** (network, DB, filesystem) when appropriate

## Structure per test

1. **Arrange**: Set up inputs and preconditions
2. **Act**: Call the function/endpoint being tested
3. **Assert**: Verify the output or side effect

## What to cover

- Normal input → expected output
- Boundary values (empty, zero, max, null)
- Invalid input → proper error handling
- Auth/permission checks (if applicable)
- Concurrent/race conditions (if applicable)
