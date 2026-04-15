---
description: Scaffold a new Remotion video project using the remotion-video skill.
---

Load the `remotion-video` skill, then scaffold a new Remotion project.

**Steps:**

1. **Ask the user (in one message, list all questions):**
   - Project name (folder name).
   - Template — default `hello-world` (TypeScript). Offer alternatives from `SETUP.md` if they want something specific (e.g. `tiktok`, `audiogram`, `next`, `tailwind`, `three`, `recorder`).
   - Dimensions — default 1920×1080. Offer 1080×1920 (vertical), 1080×1080 (square), 3840×2160 (4K).
   - fps — default 30.
   - Duration in seconds — default 5.
   - Whether to install `@remotion/google-fonts` and `@remotion/transitions` upfront (default yes — they're needed for almost every real video).

2. **Scaffold:**
   ```bash
   npx create-video@latest <project-name> --<template>
   ```
   Run from the current working directory. If `npx create-video` is interactive and a non-default template is selected, pass it via the `--<template>` flag so it doesn't prompt.

3. **Apply the user's chosen dimensions/fps/duration** by editing `src/Root.tsx` — set `width`, `height`, `fps`, `durationInFrames` (compute as `Math.round(seconds * fps)`) on the registered `<Composition>`.

4. **Install extras** if the user said yes:
   ```bash
   cd <project-name> && npm install @remotion/google-fonts @remotion/transitions
   ```

5. **Verify** by running `npm run start` (Studio) in the background — confirm it boots without errors. Stop the process and report the URL the user can open.

6. **Final report:** print the project path, dimensions/fps/duration, the composition id, and the two commands the user will use most:
   - `npm run start` — open Studio
   - `npx remotion render <comp-id> out.mp4` — render

If anything fails (network, missing Node 20+, license prompt during `npm install`), surface the error verbatim and stop — don't paper over it.

Reference: skill files at `~/.claude/skills/remotion-video/` (`SKILL.md`, `SETUP.md`, `CORE_API.md`, `PATTERNS.md`, `RENDERING.md`, `GOTCHAS.md`, `PACKAGES.md`).
