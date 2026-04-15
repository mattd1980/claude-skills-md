Do the work silently. Show me only the final result.

Everything from /lazy applies (autonomous, quality, do it yourself), PLUS:

## Silent mode

- **No play-by-play** — don't narrate each step as you do it
- **No status updates** — "now compiling...", "now testing..." — skip all of that
- **No tool-by-tool commentary** — just chain your actions
- **At the end**, give me ONE concise summary:
  - What you did (2-3 bullet points)
  - What changed (files modified)
  - Result (tests passing, screenshot if UI, any issues)

## Example output

> - Added rate limiting to `/api/webhooks` (10 req/min)
> - Added tests in `test/webhooks.test.js` (6 passing)
> - Files: `routes/webhooks.ts`, `test/webhooks.test.js`

That's it. No preamble, no "Let me...", no "Here's what I did:". Just the facts.
