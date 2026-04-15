---
description: Audit an Xceed blog article for Yoast compliance, HTML quality, anti-AI-slop, and WordPress readiness
---

# Review Xceed Blog Post

Run a full audit of an existing blog article. Fix everything you find.

## Input
$ARGUMENTS should be a folder name (e.g., `datagrid-binding-2026`). The article lives in `T:\datagrid_wpf_blog\[folder]\`.

If no folder provided, list available folders and ask which to review.

## Step 1: Load the article
- Read `article.md`, `article-elementor.html`, and `article-elementor-no-screenshots.html`
- If any file is missing, note it in the report

## Step 2: Yoast pre-flight
Write and run a Node.js script that checks:
1. Passive voice % (target: <10%)
2. Transition word % (target: >30%)
3. Consecutive sentence starters - check BOTH paragraph-level AND sentence-level within paragraphs (target: 0 matches of 3+)
4. Paragraph word counts (target: all <150)
5. Keyword occurrences (target: 4-10 each)
6. Total word count
7. Average sentence length (target: <20 words avg, <25% over 20 words)

## Step 3: Anti-AI-slop scan
Scan the article.md for:
1. **Em dashes** (Unicode U+2014) - replace with regular hyphens surrounded by spaces
2. **Banned phrases**: "dive in", "dive deep", "it's worth noting", "in today's", "whether you're a", "without further ado", "in conclusion", "comprehensive guide", "cutting-edge", "game-changer", "take your X to the next level", "in the world of", "look no further", "navigating the complexities", "stands out as", "has emerged as", "boasts", "powerful yet intuitive", "delve into", "when it comes to", "this is where X really shines"
3. **Banned words**: robust, leverage, utilize, streamline, empower, harness, unlock, seamlessly, effortlessly, elevate, supercharge, revolutionize, transformative, unprecedented, pivotal, groundbreaking, embark, fostering, myriad, plethora, paradigm, synergy
4. **Hedging filler**: essentially, basically, fundamentally, really, very, truly, absolutely, incredibly
5. **Fake enthusiasm**: exclamation marks in technical content
6. Report each violation with line number and suggested replacement

## Step 4: HTML quality
Verify both HTML files:
1. **Content wrapped in `<section>` tags** - all content must be inside `<article><section>...</section></article>`. Without this WordPress layout breaks
2. **All body text in `<p>` tags** - find bare text outside `<pre>`, `<style>`, `<script>`, `<table>`, `<ul>`, `<div>`
3. **No `<code>` tags outside `<pre>` blocks** - scan for stray inline code formatting
4. **No em dashes** in HTML files
5. **CTA box content has `<p>` tags**
6. **Images use WordPress block markup** - `<!-- wp:image -->` with `<figure>` wrapper and width attribute for sizing
7. **JSON-LD FAQ schema present** - check for `<script type="application/ld+json">`
8. **JSON-LD answers match the actual FAQ text** in the HTML
9. **Both HTML files are in sync** - diff the prose content (ignore `<img>` and `<figure>` tags) and flag mismatches
10. **Prism.js scripts present** at bottom
11. **Style block has `!important` overrides** on code block styles

## Step 5: Content quality
1. **No backtick code formatting in prose** - scan markdown for backticks around single words outside code fences
2. **Focus keyword in title, first paragraph, meta description, slug, and at least one H2**
3. **Internal and external links present** - at least 3 internal (xceed.com) and 2 external
4. **Validate every link** - use WebFetch on each URL to confirm it loads. Report dead links with line numbers
5. **Image alt text includes keyword** (at least one)
6. **FAQ section has 4+ questions with `###` subheadings**
7. **Breadcrumb title defined** in metadata

## Step 6: Demo project
1. Does a demo project folder exist?
2. Run `dotnet build` - does it compile?
3. Do the XAML/C# snippets in the article match the demo project code?

## Step 7: WordPress post check
If a WordPress draft ID is known (check memory/project_status.md):
1. Fetch the post via API and verify:
   - Categories set (must include "All" ID 141)
   - Tags set (at least 5)
   - Slug matches article metadata
   - Content uses raw format (not sanitized)
   - Images have WordPress URLs (not local paths)
2. Report what the user still needs to set manually:
   - Yoast focus keyphrase
   - Featured image

## Step 8: Report
Present a clear scorecard:

```
YOAST SCORES
  Passive voice:      X.X% (pass/fail target <10%)
  Transition words:   X.X% (pass/fail target >30%)
  Consecutive starts: X    (pass/fail target 0)
  Max paragraph:      X words (pass/fail target <150)
  Avg sentence:       X.X words (pass/fail target <20)

KEYWORDS
  "keyword 1": X occurrences (pass/fail target 4-10)
  "keyword 2": X occurrences (pass/fail target 4-10)

AI SLOP
  Em dashes:          X found (pass/fail target 0)
  Banned phrases:     X found (pass/fail target 0)
  Banned words:       X found (pass/fail target 0)
  Filler words:       X found (pass/fail target 0)

HTML QUALITY
  <section> wrapper:  pass/fail
  <p> tags:           pass/fail
  No stray <code>:    pass/fail
  WP image blocks:    pass/fail
  JSON-LD present:    pass/fail
  JSON-LD synced:     pass/fail
  Files in sync:      pass/fail

CONTENT
  Keyword in title:   pass/fail
  Keyword in H2:      pass/fail
  Keyword in meta:    pass/fail
  Keyword in slug:    pass/fail
  Internal links:     X found (pass/fail target >=3)
  External links:     X found (pass/fail target >=2)
  FAQ questions:      X

LINKS (validated)
  [list every link with pass/fail]

DEMO PROJECT
  Compiles:           pass/fail

WORDPRESS
  Categories:         pass/fail
  Tags:               X set
  Content format:     raw/sanitized
```

## Step 9: Auto-fix
After presenting the report, automatically fix all issues found:
- Replace em dashes with hyphens in all three files
- Replace banned words/phrases with plain alternatives
- Fix missing `<section>` wrapper
- Fix missing `<p>` tags
- Update WordPress post if needed (using raw content format)
- Re-run the Yoast check to confirm fixes

If the user says "fix" or "fix it" at any point, apply all fixes automatically.
