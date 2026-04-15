---
name: remotion-video
description: Build videos programmatically with Remotion (React-based video framework). Use when scaffolding a new video project, authoring Compositions/Sequences, animating with useCurrentFrame/interpolate/spring, working with Audio/Video/Img/staticFile, rendering via `remotion render` / Studio / Lambda, or debugging frame-based animation issues. Trigger on files importing from "remotion" or any "@remotion/*" package, on remotion.config.ts, or when the user mentions Remotion, programmatic video, or MP4/WebM generation from React.
---

# Remotion video skill

Remotion renders React components to video frame-by-frame. Every pixel is computed from `useCurrentFrame()` — there is no real-time clock. Internalize that and most Remotion code writes itself.

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

## Non-negotiable rules

1. **Animation is driven by `useCurrentFrame()`**, never `Date.now()`, `setTimeout`, `setInterval`, `requestAnimationFrame`, or CSS `transition`/`animation`. CSS keyframes break frame-accurate rendering.
2. **Use Remotion media primitives**: `<Audio>`, `<Video>`/`<OffthreadVideo>`, `<Img>`. Raw `<video>`/`<audio>`/`<img>` desync or miss from the output.
3. **Assets**: anything not a URL must live in `public/` and be resolved with `staticFile('path/in/public.ext')`. Don't `import` mp4/png paths. Don't prefix with `/public`.
4. **`interpolate` ranges must be strictly monotonic** and you almost always want `{extrapolateLeft: 'clamp', extrapolateRight: 'clamp'}` — otherwise values shoot past their endpoints.
5. **Randomness must be deterministic** — use `random(seed)` from `remotion`, not `Math.random()`. Otherwise each frame renders differently.
6. **Composition renders under SSR** during bundling. No `window`/`document` at module top-level. Guard with `typeof window !== 'undefined'` or `useEffect`.
7. **`durationInFrames` is an integer ≥ 1**. The last rendered frame is `durationInFrames - 1`. Convert seconds: `durationInFrames = seconds * fps`.

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
- [`CORE_API.md`](CORE_API.md) — Composition, Sequence, hooks, interpolate, spring, media components — with signatures and examples.
- [`PATTERNS.md`](PATTERNS.md) — fade, slide, stagger, typewriter, parallax, camera moves, audio-reactive.
- [`RENDERING.md`](RENDERING.md) — CLI, props passing, Zod schemas, Lambda, Cloud Run, programmatic API.
- [`GOTCHAS.md`](GOTCHAS.md) — the full list of pitfalls with fixes.

## Key docs

- Fundamentals: https://www.remotion.dev/docs/the-fundamentals
- Animating: https://www.remotion.dev/docs/animating-properties
- CLI: https://www.remotion.dev/docs/cli
- Lambda: https://www.remotion.dev/docs/lambda
- License (commercial use): https://www.remotion.dev/docs/license — companies with 4+ employees need a paid license; flag this to the user on any commercial project.
