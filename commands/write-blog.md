---
description: Write an Xceed blog post with full Yoast SEO compliance, Elementor HTML, JSON-LD schema, and a demo project
---

# Write Xceed Blog Post

You are writing a blog post for the Xceed website (xceed.com). Follow every rule below precisely - these come from hard-won Yoast SEO battles. Do NOT skip any step.

## Input Required
The user will provide:
- **Product** to write about (e.g., DataGrid for WPF, Toolkit Plus for WPF)
- **Target keywords** (e.g., "WPF DataGrid", "WPF toolkit")
- **Any specific topics/features** to cover

If not provided, ask before proceeding.

## Step 1: Research
- Search the web for the product's current version, NuGet package name, feature list, and pricing
- Check the existing articles in `T:\datagrid_wpf_blog\` for structure reference
- Verify all facts (version numbers, .NET support, control counts)

## Step 2: Write article.md
Create `T:\datagrid_wpf_blog\[topic-folder]\article.md` following these STRICT rules:

### Metadata (top of file)
```
<!-- Meta description: [~155 chars max, include primary focus keyword] -->
<!-- Excerpt: [2-3 sentences, include focus keywords] -->
<!-- Focus keywords: [primary, secondary, tertiary] -->
<!-- Slug: [url-friendly-slug] -->
<!-- Breadcrumb title: [short version of title] -->
```

### Title
- Include the primary keyword
- Use a number if possible (e.g., "103 WPF UI Controls...")
- Create curiosity - AI Overview and Google love specific, answerable titles

### Yoast SEO Rules (MANDATORY - check ALL before delivering)

**Passive Voice: Max 10%**
- Make the actor the subject: "Microsoft added" not "was added"
- Linking verbs are NOT passive

**Consecutive Sentences: NEVER 3+ starting with same word**
- This applies at BOTH levels: consecutive paragraphs AND consecutive sentences within a paragraph
- Watch for lists disguised as sentences: "No X. No Y. No Z." - combine with commas instead
- Vary every sentence opener - especially watch "No... No... No...", "The... The... The..."

**Paragraph Length: Max 150 words per paragraph**
- Split at natural topic shifts

**Transition Words: At least 30% of sentences**
- Use naturally throughout: however, therefore, consequently, for example, similarly, meanwhile, specifically, additionally, instead, furthermore, as a result, in fact, on the other hand, what's more, ultimately, fortunately, importantly, whereas, rather, after all, indeed, because, since, yet, but, so, also, while
- Don't just sprinkle at starts - use mid-sentence too: "since WPF's model...", "but they aren't..."
- Join short sentences with transitions to hit the target

**Focus Keywords**
- Primary keyword in: title, first paragraph, meta description, slug, at least one H2
- All keywords should appear 4-10 times each throughout the article
- Use **bold** for keyword phrases in body text
- Include keyword in at least one image alt text

**Internal & External Links**
- Link to other Xceed blog posts and product pages (internal)
- Link to relevant external resources (GitHub repos, NuGet pages, Microsoft docs)
- If other Xceed articles exist in the project, cross-link them
- **Validate every link before delivering** - use WebFetch on each URL to confirm it loads (200 OK). Do NOT include dead links. If a link fails, find the correct URL or remove it
- Target: at least 3 internal links (xceed.com) and 2 external links
- Good internal link targets: product pages, blog posts, documentation, trial page
- Good external link targets: NuGet packages, GitHub repos, Microsoft docs

**Sentence Length**
- Max 20 words average, no more than 25% over 20 words

**Subheadings**
- Use a subheading every ~300 words

### Formatting Rules
- NEVER use backticks or `<code>` tags for control names in prose text - plain text only
- Code formatting is ONLY for actual code blocks (XAML/C# snippets inside ``` fences)
- Control names like DateTimePicker, PropertyGrid, TextBox = plain text in paragraphs, bullet lists, FAQ answers

### Article Structure
1. **Hook** - challenge conventional wisdom, state the problem
2. **Context** - what's missing, what the industry looks like
3. **Product positioning** - what Xceed offers, NuGet install
4. **Proof** - demo project on .NET 10, project file
5. **Feature highlights** - XAML code examples, descriptions
6. **Comparison table** (if applicable) - feature matrix
7. **When NOT to use** - builds credibility
8. **CTA** - trial link, NuGet link
9. **FAQ section** - 4-6 questions targeting long-tail searches, `###` subheadings

### Tone
- Conversational but authoritative
- No marketing fluff - state facts, show code
- Address reader directly: "If you need...", "You'd have to..."
- Be honest about alternatives
- Write like a senior dev explaining to a peer, not a brochure

### Anti-AI-Slop Rules (MANDATORY)
Every sentence must pass the "would a real developer actually say this?" test. If it sounds like ChatGPT wrote it, rewrite it.

**BANNED phrases - never use these, find a specific alternative:**
- "In today's rapidly evolving landscape/world/ecosystem"
- "Let's dive in / dive deep / deep dive / let's explore"
- "It's worth noting that..." / "It's important to note..."
- "Whether you're a beginner or a seasoned professional"
- "Without further ado"
- "In conclusion" / "To sum up" / "In summary"
- "Comprehensive guide/solution/overview"
- "Cutting-edge" / "state-of-the-art" / "next-generation"
- "Game-changer" / "game-changing"
- "Take your X to the next level"
- "In the world of..." / "In the realm of..."
- "Look no further"
- "Navigating the complexities of..."
- "Stands out as" / "has emerged as"
- "Boasts" (as in "boasts an impressive feature set")
- "Powerful yet intuitive"
- "Delve into"

**BANNED single words - replace with plain alternatives:**
- "Robust" → strong, solid, reliable
- "Leverage" → use
- "Utilize" → use
- "Streamline" → simplify, speed up
- "Empower" → let, enable
- "Harness" → use
- "Unlock" → enable, get
- "Seamlessly" → smoothly, without friction
- "Effortlessly" → easily
- "Elevate" → improve
- "Supercharge" → speed up, improve
- "Revolutionize" → change, improve
- "Transformative" → useful, significant
- "Unprecedented" → new, unusual
- "Pivotal" → important
- "Groundbreaking" → new
- "Embark" → start
- "Fostering" → building, encouraging
- "Myriad" → many
- "Plethora" → many
- "Paradigm" → pattern, model
- "Synergy" → (just don't)

**BANNED punctuation:**
- NEVER use the em dash (the long dash, Unicode U+2014). Use a regular hyphen surrounded by spaces ( - ) instead. Em dashes are a dead giveaway for AI-generated text. If you see one in your output, replace it immediately.

**Writing patterns to avoid:**
- Starting paragraphs with "When it comes to..."
- Rhetorical questions that answer themselves: "But what makes X so special? The answer is..."
- Empty transitions: "Now, let's take a look at..." - just show the thing
- Overqualifying: "really", "very", "truly", "absolutely", "incredibly"
- Hedging filler: "essentially", "basically", "fundamentally"
- Fake enthusiasm: exclamation marks in technical content
- Lists of three buzzwords: "fast, flexible, and powerful"
- Sentences that say nothing: "This is where X really shines"

**What to do instead:**
- Be specific: "handles 2 million rows" not "handles massive datasets"
- Be direct: "Use DataGridCollectionView" not "You might want to consider leveraging"
- Show, don't tell: code speaks louder than adjectives
- If you can delete a sentence without losing information, delete it
- Prefer short Anglo-Saxon words over long Latin-derived ones

## Step 3: Create demo project
- Create a .NET 10 WPF project in `T:\datagrid_wpf_blog\[DemoProjectName]\`
- Reference the correct NuGet package
- Include working XAML demonstrating key controls
- **Every XAML and C# snippet used in the blog post MUST come from this project** - write the demo first, then copy snippets into the article
- **Run `dotnet build` and confirm 0 errors before proceeding** - if a control doesn't exist or a property is wrong, fix it in both the demo and the article
- If build fails, investigate the actual API (check the XML docs in the NuGet package) - never guess control names or properties
- **Add license key placeholder** in App.xaml.cs: `Xceed.Wpf.Toolkit.Licenser.LicenseKey = "YOUR-LICENSE-KEY-HERE";` (or the appropriate Licenser class for the product). Xceed packages compile without a key but throw at runtime - the user needs to insert their key before running
- Tell the user they need to insert their license key before they can run the demo or take screenshots

## Step 4: Run Yoast pre-flight check
Write and run a Node.js script that checks:
1. Passive voice % (target: <10%)
2. Transition word % (target: >30%)
3. Consecutive sentence starters - check BOTH paragraph-level AND sentence-level within paragraphs (target: 0 matches of 3+)
4. Paragraph word counts (target: all <150)
5. Keyword occurrences (target: 4-10 each)
6. Total word count

**Do NOT proceed to HTML until all targets are met.** Fix issues and re-run the check.

## Step 5: Generate Elementor HTML
Create two files:
- `article-elementor.html` (with `<img>` tags for screenshots)
- `article-elementor-no-screenshots.html` (without)

### HTML Structure
The article content MUST be wrapped in `<article>` then `<section>` tags. Without `<section>`, the WordPress layout breaks completely:
```html
<article>
<style>/* styles here */</style>
<section>
  <!-- ALL article content goes inside this section -->
  <h2>...</h2>
  <p>...</p>
  <!-- etc -->
</section>
</article>
```

### HTML Rules
- **ALL body text wrapped in `<p>` tags** - Yoast sees bare text as one giant paragraph. This is the #1 cause of "paragraph too long" errors
- **ALL content inside `<section>` tags** - without this the layout looks broken in WordPress
- Text inside `<div class="cta-box">` must also use `<p>` tags
- Lists in `<ul><li>` tags
- Code blocks use Prism.js syntax highlighting with `<pre class="language-xxx"><code>` and `<span class="token">` markup
- **NO `<code>` tags anywhere outside `<pre>` blocks** - not in paragraphs, not in lists, not in FAQ answers, nowhere
- Include the standard `<style>` block with `!important` overrides for dark code themes (WordPress theme CSS overrides without them)
- Include CTA box with `.cta-box` class and orange gradient
- Include Prism.js `<script>` tags at bottom
- **Both HTML files must stay in sync** - every prose change must go into both versions
- **Images** use WordPress block markup for proper sizing (WordPress strips raw inline styles):
```html
<!-- wp:image {"width":"525px","sizeSlug":"full"} -->
<figure class="wp-block-image size-full is-resized"><img src="URL" alt="ALT" style="width:525px" /></figure>
<!-- /wp:image -->
```

### JSON-LD FAQ Schema
Add a `<script type="application/ld+json">` block after `</article>` with FAQPage schema containing all FAQ Q&As. This enables Google rich results and AI Overview.

### Style Block Template
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
  pre[class*="language-"] { margin: 2rem 0 !important; padding: 1rem 1.25rem !important; overflow-x: auto !important; font-size: 0.9rem !important; line-height: 1.5 !important; border-radius: 10px !important; background: #1e1e1e !important; border: 1px solid #333 !important; color: #d4d4d4 !important; }
  pre[class*="language-"] code { background: none !important; padding: 0 !important; color: #d4d4d4 !important; font-family: Consolas, Monaco, 'Courier New', monospace !important; }
  pre[class*="language-"] code span { color: inherit; }
  pre[class*="language-"] .token.tag { color: #569cd6 !important; }
  pre[class*="language-"] .token.attr-name { color: #9cdcfe !important; }
  pre[class*="language-"] .token.attr-value { color: #ce9178 !important; }
  pre[class*="language-"] .token.punctuation { color: #808080 !important; }
  pre[class*="language-"] .token.namespace { color: #4ec9b0 !important; }
  pre[class*="language-"] .token.keyword { color: #569cd6 !important; }
  pre[class*="language-"] .token.class-name { color: #4ec9b0 !important; }
  pre[class*="language-"] .token.string { color: #ce9178 !important; }
  pre[class*="language-"] .token.comment { color: #6a9955 !important; }
  pre[class*="language-"] .token.property { color: #9cdcfe !important; }
  pre[class*="language-"] .token.operator { color: #d4d4d4 !important; }
</style>
```

## Step 6: Publish to WordPress
If the user has configured WordPress credentials, create/update the post via REST API. Use Node.js `https` module for all API calls (curl POST fails on Windows with large payloads).

### Setup (one-time)
The user needs to set environment variables (never store credentials in files):

```
WP_SITE_URL=https://xceed.com
WP_USERNAME=the-username
WP_APP_PASSWORD=xxxx xxxx xxxx xxxx xxxx xxxx
```

Set these via Windows Settings > System > Advanced > Environment Variables, or in PowerShell:
```powershell
[Environment]::SetEnvironmentVariable("WP_SITE_URL", "https://xceed.com", "User")
[Environment]::SetEnvironmentVariable("WP_USERNAME", "the-username", "User")
[Environment]::SetEnvironmentVariable("WP_APP_PASSWORD", "xxxx xxxx xxxx xxxx", "User")
```

The Application Password is generated at wp-admin > Users > Profile > Application Passwords.

**Before calling the API**, check that env vars are set. If not, skip this step and tell the user how to set them up.

### Step 6a: Create the draft post
Use `POST /wp-json/wp/v2/posts` with:
- `title` - article title
- `content` - **MUST use raw format**: `{ content: { raw: htmlString } }` NOT `{ content: htmlString }`. WordPress strips inline styles, CSS classes, block markup, and image sizing when you pass a plain string. The raw format bypasses the sanitizer.
- `excerpt` - from article metadata
- `slug` - from article metadata
- `status` - always `"draft"`, never publish automatically

### Step 6b: Upload screenshots and set featured image
If the demo project has a screenshot capture mode (--screenshots flag):
1. Run the demo with `dotnet run -- --screenshots` to auto-capture screenshots
2. Upload each screenshot to WordPress media library via `POST /wp-json/wp/v2/media` with:
   - `Content-Type: image/png`
   - `Content-Disposition: attachment; filename="screenshot.png"`
   - Set `alt_text` on each image (include the focus keyword in at least one)
3. Update the post content - replace placeholder paths (`screenshots/01-xxx.png`) with the real WordPress URLs
4. Set the first screenshot as the **featured image** via `featured_media` field on the post

### Step 6c: Set categories and tags
**Categories** - Always set via the `categories` array field on the post:
- Always include **"All" (ID 141)**
- Add the relevant category: **Tutorials (60)**, News (52), Release Notes (78)

**Tags** - Generate 8-10 relevant tags based on keywords, product names, and technologies:
1. Search for existing tags via `GET /wp-json/wp/v2/tags?search=tagname`
2. If not found, create via `POST /wp-json/wp/v2/tags` with `{ "name": "tag name" }`
3. Handle `term_exists` errors - extract the existing `term_id` from `err.data.term_id`
4. Set all tag IDs via the `tags` array field on the post

### Step 6d: Set post settings
Update the post via `POST /wp-json/wp/v2/posts/{id}`:

```json
{
  "comment_status": "open",
  "ping_status": "closed"
}
```

Note: Always use `{ content: { raw: html } }` when updating content. All content updates must use the raw format.

### What we CANNOT automate
- **Yoast focus keyphrase** - the `_yoast_wpseo_focuskw` meta field is not exposed through the REST API on this WordPress install. The user must set it manually in the Yoast panel in the editor. ALWAYS remind the user to do this.
- **Featured image** - user sets this manually in WordPress
- Yoast analysis score (runs client-side in the editor, not server-side)
- Publishing (user reviews and publishes manually)

## Step 7: Deliver summary
Tell the user:
- Article word count and Yoast scores
- Keyword counts
- WordPress draft URL with edit link
- What was set automatically: categories, tags, screenshots, post settings
- **ALWAYS remind the user they need to manually set:**
  1. Yoast focus keyphrase (tell them the exact keyword to enter)
  2. Featured image
  3. Review content and publish
  4. Verify JSON-LD at Google's Rich Results Test after publishing
- If screenshots couldn't be auto-captured (no license key), remind the user to insert their key and run the demo with `--screenshots`

---

## Step 8: Run /review-blog
As the final step, run `/review-blog [folder-name]` on the article you just created. This catches anything the writing steps missed - AI slop, HTML issues, missing section tags, em dashes, etc. Fix all issues before delivering to the user.

---

## Arguments
$ARGUMENTS contains a product/topic and keywords (e.g., "Xceed DataGrid targeting WPF DataGrid").

To review an existing article, use `/review-blog [folder-name]` instead.

If $ARGUMENTS is empty, ask the user what they want to do.
