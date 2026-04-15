Analyze and improve performance of the specified code.

Target: $ARGUMENTS

## Steps

1. **Profile**: Identify where time/memory is actually spent
   - Don't guess — measure or reason from the code
   - Look for: N+1 queries, unnecessary re-renders, unbounded loops, large payloads

2. **Categorize bottlenecks**:
   - **I/O bound**: DB queries, network calls, file reads
   - **CPU bound**: Parsing, sorting, encryption, serialization
   - **Memory bound**: Large objects in memory, leaks, excessive copying

3. **Propose fixes** with expected impact:
   | Fix | Effort | Impact | Trade-off |
   |-----|--------|--------|-----------|

4. **Implement** the highest-impact, lowest-effort fixes first

5. **Verify**: Measure improvement (before/after timing, reduced queries, etc.)

## Common wins
- Add database indexes for frequent queries
- Batch multiple DB calls into one
- Cache expensive computations
- Paginate large result sets
- Debounce/throttle frequent operations
- Lazy load what's not immediately needed
