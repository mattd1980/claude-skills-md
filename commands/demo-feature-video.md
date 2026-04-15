---
description: Produce a Remotion video demonstrating a feature the user just built — infers context from recent work, proposes a structure, then builds it.
---

You are producing a short demo video for a feature the user has been building. Use the `remotion-video` skill for all technical execution — your job here is **direction**: structure, pacing, asset choices, narrative.

## Phase 1 — Infer what the video is about

Before asking anything, gather context:

1. **Recent conversation** — what feature has the user been building or discussing?
2. **`git log --oneline -20`** and **`git diff main...HEAD`** (or `git diff HEAD~5`) — what actually shipped?
3. **README / package.json** — what's the product, what's its tone?

Synthesize a one-paragraph **brief** in your head: *"User shipped X, which does Y for audience Z. The video should show A, B, C."* Don't write this out yet — use it to inform the questions.

## Phase 2 — Ask targeted questions (one message, all at once)

Ask only what you can't infer. Group as:

**About the video**
- Confirm the feature/topic — state your inferred brief and ask "is that right?"
- Audience — devs / end-users / executives / mixed?
- Target length — short (15–30s), standard (45–90s), or long (2–3 min)?
- Distribution — landing page / social (vertical) / docs / internal demo? This drives dimensions.
- Voiceover — yes/no, and if yes, do they have a script or want you to draft captions instead?

**About assets**
- Logo (path or "skip")
- Brand colors (hex, or "use defaults")
- Preferred font (Google Fonts name, or "Inter")
- Background music (path in `public/`, or "skip")
- Screen recordings or screenshots of the feature (paths, or "I'll add later — leave placeholders")

**About the project context**
- Existing Remotion project to add to, or scaffold a new one?

## Phase 3 — Propose a structure

Build a scene-by-scene plan based on the brief + their answers. Default playbook for a feature demo (adapt to length):

| Scene | Duration | Purpose |
|---|---|---|
| **Title card** | 2–3s | Feature name + product logo. Spring-in, hold, transition out. |
| **The problem** (optional, skip if obvious) | 3–5s | One-line statement of pain point. Often a short text card or a "before" screenshot. |
| **The demo** | 60–70% of total | The actual feature in action. Screen recording, screenshots with callouts, or a code zoom. Pace for comprehension — hold each beat 1.5–2.5s. |
| **Key takeaway** | 3–5s | One sentence: what the viewer should remember. Big text, brand color. |
| **Outro / CTA** | 2–3s | Logo + URL or "try it now". Mirror the title card for symmetry. |

**Pacing rules:**
- Cuts between similar shots: 0.4–0.5s (`linearTiming({durationInFrames: 12-15})` at 30fps).
- Scene changes: 0.6–0.8s with `fade()` or `slide()`.
- Hold a screenshot: 1.5s minimum, 2.5s if there's something to read.
- Title cards: enter (12–18 frames), hold (45–60 frames), exit (12–18 frames).

**Visual judgment:**
- One callout per shot, max. More = noise.
- Highlight cursor positions / clicked elements with a circle that grows then fades (`spring` for entrance, `interpolate` for exit).
- For code: zoom + dim the surrounding lines instead of showing the whole file.
- Background music ducks under voiceover (volume 0.6 → 0.2). If no VO, hold at 0.5–0.6.

Present the proposed structure as a numbered list with: scene name, duration in seconds and frames, what's on screen, what the viewer should feel/learn. **Stop and wait for the user to approve or revise.**

## Phase 4 — Build

Once approved:

1. Confirm the `remotion-video` skill is loaded (its rules apply: `useCurrentFrame`-driven, Remotion media primitives, `staticFile`, `delayRender` for fonts/data, `trimBefore`/`trimAfter` for media).
2. If new project: invoke `/create-video` with the chosen dimensions/fps/duration, then add to it. Otherwise, add scenes to the existing project.
3. Use `<TransitionSeries>` to compose scenes — one `<TransitionSeries.Sequence>` per scene from the structure, with a `<TransitionSeries.Transition>` between each.
4. Load the chosen font with `@remotion/google-fonts/<Family>`.
5. Drop user-provided assets into `public/`. Where assets are missing, use clearly-labeled placeholders (`<AbsoluteFill style={{background: '#222', display: 'flex', alignItems: 'center', justifyContent: 'center'}}><span>SCREENSHOT: feature-X.png</span></AbsoluteFill>`) and list them at the end so the user knows what to add.
6. Set `Composition.durationInFrames` to the sum of scene durations (account for transition overlap — `TransitionSeries` overlaps by the transition's duration).
7. Boot Studio (`npm run start`) and report the URL.

## Phase 5 — Report

Final message must include:
- Project path and composition id.
- Total duration (seconds and frames).
- A list of placeholders the user needs to provide assets for.
- The render command: `npx remotion render <comp-id> demo.mp4`.
- One concrete next-iteration suggestion (e.g. "the problem scene feels short — want me to extend it to 5s?").

## Tone

You are a director, not a documentation engine. Make calls. When the user says "make it punchier" or "this scene drags", change the timing values — don't ask which numbers.
