---
name: remotion-video
description: Build videos programmatically with Remotion (React-based video framework). Use when scaffolding a new video project, authoring Compositions/Sequences, animating with useCurrentFrame/interpolate/spring, working with Audio/OffthreadVideo/Img/staticFile, using delayRender for async work, rendering via `remotion render` / Studio / Lambda, embedding a `<Player>`, or debugging frame-based animation issues. Trigger on files importing from "remotion" or any "@remotion/*" package, on remotion.config.ts, or when the user mentions Remotion, programmatic video, MP4/WebM generation from React, or embedding a Remotion Player.
---

# Remotion video skill

Remotion renders React components to video frame-by-frame. Every pixel is computed from `useCurrentFrame()` — there is no real-time clock. Internalize that and most Remotion code writes itself.

**Current major version: Remotion 4.x** (no v5 exists as of April 2026). Don't hallucinate v5 APIs.

## Confirm before writing code

Users routinely under-specify these three — confirm or state your assumption before generating a composition:

- **Dimensions** (1920×1080, 1080×1920 vertical, 1080×1080 square, 4K?)
- **fps** (30 for most platforms, 60 for smooth motion, 24 for cinematic)
- **Duration** — in seconds or frames. Convert: `durationInFrames = Math.round(seconds * fps)`.

## When this skill applies

- Scaffolding a new video project (`npx create-video@latest`).
- Writing or modifying components inside a Remotion project (detect: `remotion` in `package.json`, `remotion.config.ts`, or `registerRoot` usage).
- Rendering to MP4/WebM/GIF, or setting up Lambda/Cloud Run rendering.
- Diagnosing why an animation stutters, the audio desyncs, or the build fails — usually one of the gotchas below.

## Quick decision tree

- **User wants to start a new video** → `npx create-video@latest <name>` and pick the template (see `SETUP.md`). Default to `hello-world` (TS) unless they specify Next.js, Tailwind, Three, Skia, Remix, etc.
- **User wants to animate a value** → `spring()` for organic motion, `interpolate()` for linear/custom curves. Always clamp. See `CORE_API.md`.
- **User wants to sequence/time elements** → wrap in `<Sequence from={X} durationInFrames={Y}>`. `useCurrentFrame()` resets to 0 inside.
- **User wants to render** → `npx remotion render <entry?> <comp-id> <out>`. Pass props with `--props='{...}'` or `--props=./file.json`. See `RENDERING.md`.
- **User wants an audio/video/image asset** → Remotion's `<Audio>`, `<OffthreadVideo>` (preferred for mp4) or `<Video>`, `<Img>`. Never raw HTML tags. Assets go in `public/` loaded via `staticFile('name.ext')`.
- **User wants background music / SFX** → see `AUDIO.md`. Volume automation, layering, SFX-to-transition mapping, `@remotion/sfx`.
- **User wants voiceover / TTS** → see `AUDIO.md#tts-pipeline`. OpenAI TTS or ElevenLabs → whisper.cpp transcription → frame-synced captions.
- **User wants audio-reactive visuals** → see `AUDIO.md#audio-reactive-visuals`. EQ bars, beat-synced pulse, waveform ring via `visualizeAudio`.
- **User wants advanced animation** → see `PATTERNS.md#advanced-animations`. Particles, 3D transforms, path drawing/morphing, noise, motion blur, text effects.

## Non-negotiable rules

1. **Animation is driven by `useCurrentFrame()`**, never `Date.now()`, `setTimeout`, `setInterval`, `requestAnimationFrame`, or CSS `transition`/`animation`. CSS keyframes break frame-accurate rendering.
2. **Use Remotion media primitives**: `<Audio>`, `<OffthreadVideo>` (preferred for mp4) or `<Video>`, `<Img>`. Raw `<video>`/`<audio>`/`<img>` desync or miss from the output. To trim, use `trimBefore` / `trimAfter` (the old `startFrom` / `endAt` names are deprecated since 4.0.319).
3. **Assets**: anything not a URL must live in `public/` and be resolved with `staticFile('path/in/public.ext')`. Don't `import` mp4/png paths. Don't prefix with `/public`.
4. **`interpolate` ranges must be strictly monotonic** and you almost always want `{extrapolateLeft: 'clamp', extrapolateRight: 'clamp'}` — otherwise values shoot past their endpoints.
5. **Randomness must be deterministic** — use `random(seed)` from `remotion`, not `Math.random()`. Otherwise each frame renders differently.
6. **Composition renders under SSR** during bundling. No `window`/`document` at module top-level. Guard with `typeof window !== 'undefined'` or `useEffect`.
7. **`durationInFrames` is an integer ≥ 1**. The last rendered frame is `durationInFrames - 1`. Convert seconds: `durationInFrames = Math.round(seconds * fps)`.
8. **Async work during render must be wrapped in `delayRender()` / `continueRender()`**. Fonts, fetched data, image preload — without this, the renderer captures the frame before the async work finishes. See `CORE_API.md#async-work-delayrender`.
9. **Custom fonts**: use `@remotion/google-fonts` (or `delayRender` around a `FontFace.load()`). A plain `<link>` tag in HTML will race the renderer and the first frames will render with a fallback font.

## Skeleton of a Composition component

```tsx
import {AbsoluteFill, interpolate, spring, useCurrentFrame, useVideoConfig} from 'remotion';

export const MyScene: React.FC<{title: string}> = ({title}) => {
  const frame = useCurrentFrame();
  const {fps, durationInFrames} = useVideoConfig();

  const enter = spring({frame, fps, config: {damping: 12}});
  const opacity = interpolate(frame, [0, 20], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill style={{backgroundColor: '#111', justifyContent: 'center', alignItems: 'center'}}>
      <h1 style={{color: 'white', opacity, transform: `scale(${enter})`}}>{title}</h1>
    </AbsoluteFill>
  );
};
```

Register it in `src/Root.tsx`:

```tsx
import {Composition} from 'remotion';
import {MyScene} from './MyScene';

export const RemotionRoot: React.FC = () => (
  <Composition
    id="MyScene"
    component={MyScene}
    durationInFrames={150}
    fps={30}
    width={1920}
    height={1080}
    defaultProps={{title: 'Hello'}}
  />
);
```

## Supporting references

Load these only when needed — keep `SKILL.md` in context by default:

- [`SETUP.md`](SETUP.md) — scaffold commands, templates, project layout, licensing note.
- [`AUDIO.md`](AUDIO.md) — Full audio production: `<Audio>` props, `@remotion/sfx`, volume automation (6 patterns), SFX timing, layering, TTS pipeline (OpenAI + ElevenLabs + whisper.cpp), audio-reactive visuals (EQ bars, beat pulse, waveform ring).
- [`CORE_API.md`](CORE_API.md) — Composition, Sequence, hooks, interpolate, spring, media components, `delayRender` — with signatures and examples.
- [`PATTERNS.md`](PATTERNS.md) — Basic (fade, slide, stagger, parallax, Google Fonts, captions, end-to-end example) + Advanced (particles, 3D perspective, SVG path drawing, path morphing, noise-driven motion, motion blur, 5 text effects, morph transitions).
- [`RENDERING.md`](RENDERING.md) — CLI, props passing, Zod schemas, Lambda, Cloud Run, programmatic API, `<Player>` embedding.
- [`PACKAGES.md`](PACKAGES.md) — flat table of every `@remotion/*` package and what it's for.
- [`GOTCHAS.md`](GOTCHAS.md) — the full list of pitfalls with fixes.

## Key docs

- Fundamentals: https://www.remotion.dev/docs/the-fundamentals
- Animating: https://www.remotion.dev/docs/animating-properties
- CLI: https://www.remotion.dev/docs/cli
- Lambda: https://www.remotion.dev/docs/lambda
- License (commercial use): https://www.remotion.dev/docs/license — for-profit organisations with **more than 3 employees** need a paid company license; flag this to the user on any commercial project.
