---
description: Write and publish an Xceed release notes blog post with Yoast compliance and WordPress draft creation
---

# Write Xceed Release Notes Post

You are writing a release announcement blog post for the Xceed website (xceed.com). This is different from a product SEO article — it's a news/changelog post. Follow every rule below precisely.

## Input Required
The user will provide the raw release notes text. If not provided, ask for it.

## Step 1: Rewrite the release notes

Create `T:\datagrid_wpf_blog\release-[name]\article.md` with improved prose.

### Metadata (top of file)
```
<!-- Meta description: [~155 chars max, summarize the release highlights] -->
<!-- Excerpt: [2-3 sentences summarizing what shipped] -->
<!-- Focus keywords: [product names mentioned, e.g., "Xceed PDF Library"] -->
<!-- Slug: [url-friendly-slug, e.g., xceed-march-2026-release] -->
<!-- Breadcrumb title: [short, e.g., March 2026 Release] -->
```

### Writing Rules (same Yoast rules as product posts)

**Passive Voice: Max 10%**
- Release notes are HEAVILY passive by nature ("can now be", "has been added", "were updated")
- Rewrite aggressively: "Developers can now..." not "X can now be...", "The team renamed..." not "X was renamed...", "You can now..." not "It is now possible to..."
- This is the #1 issue with release posts — expect to rewrite most sentences

**Consecutive Sentences: NEVER 3+ starting with same word**
- Release notes love repeating "Developers can now..." or "This..." — vary openers

**Paragraph Length: Max 150 words**

**Transition Words: At least 30%**
- Use: furthermore, additionally, as a result, consequently, specifically, what's more, also, because, since, yet, but, so, instead, while, overall

**Sentence Length: Max 20 words average**

**Subheadings: Every ~300 words**

### Formatting Rules
- NEVER use backticks or `<code>` tags for class/property/method names in prose — plain text only
- Class names like BookmarkCollection, SplitByPageOptions, DocumentInformations = plain text
- Method names like SetColor(), SetThickness() = plain text
- Only use code formatting inside actual code blocks (if any)

### Structure for Release Posts
1. **Opening paragraph** — what shipped, what's the headline feature
2. **Product links** — link to each updated product page in the intro
3. **Major product section** (biggest update first) — H2 heading, then H3 per feature area
4. **Minor product sections** — H2 per product, brief description
5. **Suite updates** — brief mention
6. **CTA** — trial link, NuGet link, release notes link

### Tone
- Professional but not dry — "a ground-up rework" not "a major update has been released"
- Highlight what developers can DO, not what was changed
- Address reader directly where natural: "you get...", "check the migration guide if you're upgrading"

### What NOT to include (differs from product posts)
- No FAQ section
- No JSON-LD schema
- No demo project
- No comparison tables
- No "when not to use" section
- No screenshots (usually)

### Links
- Link to each product page (internal)
- Link to trial page
- Link to NuGet profile or specific packages
- Cross-link to related blog posts if they exist (e.g., the WPF DataGrid or Toolkit articles)
- **Validate every link with WebFetch before delivering**

## Step 2: Run Yoast pre-flight check
Write and run a Node.js script that checks:
1. Passive voice % (target: <10%)
2. Transition word % (target: >30%)
3. Consecutive sentence starters (target: 0)
4. Paragraph word counts (target: all <150)
5. Total word count

**Fix issues and re-run until all targets are met.**

## Step 3: Generate Elementor HTML
Create `article-elementor.html` (one file only — no screenshots version needed for release posts).

### HTML Rules
- ALL body text in `<p>` tags
- Lists in `<ul><li>` tags
- NO `<code>` tags anywhere
- Include the CTA box with `.cta-box` class
- No Prism.js scripts needed (no code blocks in release posts)
- No JSON-LD needed

### Style Block
Only include the CTA box styles (no code block styles needed):
```html
<style>
  .cta-box {
    background: linear-gradient(145deg, #ff8441 0%, #ff772e 40%, #ff7429 100%);
    color: #fff;
    border-radius: 12px;
    padding: 1.5rem 1.75rem;
    margin: 2rem 0;
    box-sizing: border-box;
    box-shadow: 0 8px 24px rgba(0,0,0,0.08), 0 4px 10px rgba(168,63,8,0.15), inset 0 1px 0 rgba(255,255,255,0.12);
  }
  .cta-box h3 { margin: 0 0 0.5rem 0; font-size: 1.25rem; font-weight: 700; color: #fff; }
  .cta-box p { margin: 0 0 1rem 0; font-size: 1rem; line-height: 1.5; color: #fff; opacity: 0.98; }
  .cta-box a.cta-link { display: inline-block; background: #fff; color: #ff671b; text-decoration: none; font-weight: 600; padding: 0.5rem 1rem; border-radius: 8px; margin-right: 0.75rem; margin-top: 0.25rem; font-size: 0.9375rem; }
  .cta-box a.cta-link:hover { background: #f5f5f5; }
</style>
```

### CTA Box Template
```html
<div class="cta-box">
<h3>Ready to update?</h3>
<p>[Summary of what shipped — customize per release]</p>
<p><a class="cta-link" href="https://xceed.com/trial/">Start your free trial</a></p>
<p><a class="cta-link" href="https://www.nuget.org/profiles/xceed">Browse NuGet packages</a></p>
</div>
```

## Step 4: Publish to WordPress as draft
If WordPress env vars are set (`WP_SITE_URL`, `WP_USERNAME`, `WP_APP_PASSWORD`):

1. Create a JSON payload with title, content (HTML), excerpt, slug, status: "draft", and Yoast meta fields
2. POST to `$WP_SITE_URL/wp-json/wp/v2/posts` using Node.js https module (curl POST fails on Windows with large payloads)
3. Report the post ID and edit URL

Use this Node.js pattern for the API call:
```javascript
var https = require('https');
var url = new URL(process.env.WP_SITE_URL + '/wp-json/wp/v2/posts');
var auth = Buffer.from(process.env.WP_USERNAME + ':' + process.env.WP_APP_PASSWORD).toString('base64');
var options = {
  hostname: url.hostname,
  path: url.pathname,
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Basic ' + auth,
    'Content-Length': Buffer.byteLength(payload)
  }
};
```

If env vars aren't set, skip and tell the user how to configure them.

## Step 5: Deliver summary
Tell the user:
- Word count and Yoast scores
- WordPress draft URL (if posted)
- What they still need to do: set featured image, category/tags, review, publish

## Arguments
$ARGUMENTS contains the raw release notes text. If empty, ask the user to paste it.
