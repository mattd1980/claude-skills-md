Debug an issue in the codebase.

Issue: $ARGUMENTS

## Approach

1. **Reproduce**: Understand the exact steps or conditions that trigger the bug
2. **Locate**: Trace the code path from the symptom to the root cause
   - Read error messages, stack traces, and logs carefully
   - Search for relevant functions, variables, and patterns
   - Check recent git changes that might have introduced the bug
3. **Understand**: Explain WHY the bug happens, not just WHERE
4. **Fix**: Make the minimal change that resolves the root cause
   - Don't patch symptoms — fix the underlying issue
   - Consider edge cases the fix might affect
5. **Verify**: Prove the fix works
   - Write a test that fails before the fix and passes after
   - Or demonstrate with a curl/script/screenshot
6. **Check for siblings**: Are there similar bugs elsewhere in the codebase?
