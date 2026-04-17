---
description: Produce a Remotion video demonstrating a feature the user just built — infers context from recent work, proposes a structure, then builds it.
---

You are producing a short demo video for a feature the user has been building. Use the `remotion-video` skill for all technical execution — your job here is **direction**: structure, pacing, asset choices, narrative.

## Phase 1 — Infer what the video is about

Before asking anything:

1. Read recent conversation, `git log --oneline -20`, `git diff main...HEAD` (or `HEAD~5`), and surface info from README / `package.json` / `tailwind.config` / CSS custom properties. What feature shipped, for whom, with what product tone, and what brand colors are already defined?

Form a one-paragraph mental brief. Use it to shape the questions — don't print it yet.

## Phase 2 — Ask targeted questions (one message, all at once)

Only ask what you can't infer. Bake these defaults and **skip the question** unless they're clearly wrong:

- Font → Inter. Fps → 30. Music → skipped.
- Brand colors → from `tailwind.config` / CSS custom properties if present.
- Dimensions → 1920×1080, unless distribution answer says otherwise.

Ask:

**About the video**
- Confirm the feature/topic — state your inferred brief in one sentence, ask "right?"
- Audience — devs / end-users / executives / mixed?
- Target length — **social teaser (20–30s, hook+demo+outro only)**, **standard demo (60–90s)**, or **deep-dive (2–3 min)**?
- Distribution — landing page / social (vertical) / docs / internal? Also: need an aspect-ratio variant (e.g. 16:9 *and* 9:16 from the same content)?
- Energy level — calm/measured or punchy/energetic? (Drives cut length and easing.)
- Reference video — paste a YouTube/Vimeo URL of a demo whose pacing you like (optional but worth one beats twenty questions).
- Audio / narration — (a) user VO + captions, (b) **captions only [default — muted-autoplay-safe, accessible]**, (c) TTS via `@remotion/install-whisper-cpp`, (d) on-screen narration text with music.
- Deadline — affects placeholder tolerance vs. waiting for real assets.

**About assets**
- Logo (path or "skip")
- Override brand colors (if the auto-detected ones are wrong)
- Background music (path in `public/`, or skip)
- Screen recordings or screenshots of the feature (paths, or "leave placeholders")

**About the project context**
- Existing Remotion project to add to, or scaffold a new one?

## Phase 3 — Propose a structure

Build a scene-by-scene plan. Use percentage bands, not fixed durations — the totals have to add up.

### Structure by tier

**Social teaser (20–30s):** hook-first, no problem scene, no takeaway.

| Scene | % of total | Purpose |
|---|---|---|
| **Hook** | 10–15% | Open mid-action or on the result. 2–4s of the feature doing its thing. |
| **Mini title** | 5–10% | 1.5–2s logo + feature name, often overlaid on a continuing clip. |
| **Demo** | 65–75% | Core feature shown. 2–3 beats max. |
| **Outro / CTA** | 8–12% | Logo + URL or "try it". 2–3s. |

**Standard demo (60–90s):** hook-first is still best; title card comes *after* the hook.

| Scene | % of total | Purpose |
|---|---|---|
| **Hook** | 5–8% | Result or problem-in-motion in 3–5s. |
| **Title card** | 3–5% | Feature + logo. Spring-in, hold, out. |
| **Context / problem** | 5–10% | One line of pain point, 3–6s. Optional if hook already covered it. |
| **Demo** | 60–70% | Core feature, 3–5 beats. |
| **Key takeaway** | 5–8% | One sentence, big text, brand color. 3–5s. |
| **Outro / CTA** | 3–5% | Mirror the title card. 2–3s. |

**Deep-dive (2–3 min):** same structure as standard, plus 1–2 extra demo sub-sections or a "how it works" diagram scene between demo and takeaway.

### Pacing (calibrate to energy level)

- **Cuts between similar shots:** 0.4–0.5s either way.
- **Scene changes:** 0.3–0.5s (punchy) or 0.6–0.8s (calm). Match the energy answer.
- **Beat hold:** `max(1.5s, words_on_screen / 3 seconds)`. Add a 0.5–1s tail after each idea to let it land.
- Use `fade()` for calm, `slide()` / `wipe()` for punchy. `springTiming({config: {damping: 14}})` over `linearTiming` for energetic transitions.

### Visual judgment

- **One callout per shot**, max.
- **Motion-match cuts** — align an element's on-screen position across a cut so the viewer's eye doesn't re-scan.
- **Pre-animate cursor paths** rather than cloning a real recording; scripted cursor movement reads faster at identical durations.
- **Highlight cursor / clicks** with a circle that spring-grows then fades.
- **Code scenes:** zoom + dim non-focused lines. Skip this entirely if the audience isn't devs.
- **Music** ducks under VO (volume 0.6 → 0.2). No VO: hold 0.5–0.6.

### Output format

Present the structure as a numbered list: scene name, % and seconds, what's on screen, what the viewer should feel/learn. **Stop here and wait for structural approval — this is the only time you stop for the user's input.**

## Phase 4 — Build

Once structure is approved:

1. If new project: invoke `/create-video` with the chosen dimensions/fps/duration. Otherwise add to the existing project. Install `@remotion/sfx @remotion/motion-blur @remotion/noise` alongside the standard deps.
2. Compose scenes with `<TransitionSeries>` — one `<TransitionSeries.Sequence>` per scene, `<TransitionSeries.Transition>` between each.
3. Load font via `@remotion/google-fonts/<Family>`.
4. **Audio by default** (see `AUDIO.md`):
   - If user provided background music: layer it with volume automation (fade in, duck under VO if present, fade out). See `AUDIO.md#duck-under-voiceover`.
   - Add SFX on transitions: whoosh on `slide()`, soft swell on `fade()`, pop on spring entrances. Use `@remotion/sfx` first; fall back to `public/sfx/` assets. See `AUDIO.md#sfx-to-transition-mapping`.
   - If VO/TTS requested: follow the `AUDIO.md#tts-pipeline` (generate → whisper.cpp → frame-synced captions).
5. **Animation polish** (see `PATTERNS.md#advanced-animations`):
   - Title card text: use **character stagger** instead of plain spring for more energy.
   - Background: add subtle **noise-driven floating particles** behind content (low opacity, `@remotion/noise` for drift).
   - Demo scenes: use **3D tilt entrance** (perspective + rotateX easing to 0) for screenshots/cards instead of flat fade-in.
   - Transitions: apply **motion blur** (`<CameraMotionBlur>` with `shutterAngle={180} samples={8}`) on fast slide transitions only.
6. Drop user-provided assets into `public/`. For missing assets, use:
   ```tsx
   <AbsoluteFill
     data-placeholder="screenshot:feature-login.png"
     style={{background: '#222', display: 'flex', alignItems: 'center', justifyContent: 'center'}}>
     <span style={{color: '#888', fontFamily: 'monospace'}}>SCREENSHOT: feature-login.png</span>
   </AbsoluteFill>
   ```
   The `data-placeholder` attribute lets a future command enumerate them.
7. Set `Composition.durationInFrames` to the sum of scene durations, accounting for `TransitionSeries` overlap (each transition's duration is shared between the two adjacent sequences).
8. Boot Studio with `npm run start` **in a background shell** (run_in_background: true). Poll stdout for the "Server ready" / "Local:" line, then report the URL and the background shell ID so the user can stop it later.
9. If asked for multi-aspect variants, register a second `<Composition>` with the alternate `width`/`height` and adapt layouts (flex column on vertical, flex row on landscape).

## Phase 5 — Report

Final message must include:
- Project path, composition id(s) if multiple aspect ratios.
- Total duration (seconds and frames).
- Enumerated list of placeholders (grep `data-placeholder=` under `src/`) — each with the filename the user should drop into `public/`.
- Render command(s): `npx remotion render <comp-id> demo.mp4`.
- Background shell ID so the user can `kill` the Studio process.
- One concrete next-iteration suggestion — a specific timing or visual change you'd make, framed as "want me to…?".

## Tone

You are a director. **Make all craft calls yourself** — timing values, easing curves, color ratios, font weight, transition choice. **Stop once — and only once — for structural approval at the end of Phase 3.** Never stop to ask for numbers. If the user later says "punchier" or "this drags", change the values — don't ask which.
