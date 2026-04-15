# Remotion core API

Everything imported from `'remotion'` unless noted.

## `<Composition>` — register a renderable video

```tsx
<Composition
  id="MyVideo"                       // unique id, used by `remotion render`
  component={MyVideo}                 // React component (not JSX)
  durationInFrames={150}              // integer >= 1
  fps={30}
  width={1920}
  height={1080}
  defaultProps={{title: 'Hi'}}        // must match component props
  schema={z.object({title: z.string()})}  // optional Zod schema -> Studio editor UI
/>
```

## Hooks

### `useCurrentFrame(): number`
Current frame, 0-indexed. Resets to 0 inside a `<Sequence>`.

### `useVideoConfig(): {fps, durationInFrames, width, height}`
Composition metadata. `durationInFrames` inside a `<Sequence>` is the sequence's duration.

## `<Sequence>` — time-shift and clip children

```tsx
<Sequence from={30} durationInFrames={60} name="Intro">
  {/* useCurrentFrame() here returns 0 at frame 30, 59 at frame 89 */}
  <Intro />
</Sequence>
```

- `from` is the parent-frame at which the sequence starts.
- `durationInFrames` clips the sequence; omit for "until end".
- Children outside `[from, from+duration)` don't render.
- Nesting works — each sequence reframes `useCurrentFrame`.

### `<Series>` — sequential sequences

```tsx
import {Series} from 'remotion';

<Series>
  <Series.Sequence durationInFrames={30}><SceneA /></Series.Sequence>
  <Series.Sequence durationInFrames={60}><SceneB /></Series.Sequence>
  <Series.Sequence durationInFrames={30} offset={-10}><SceneC /></Series.Sequence>
</Series>
```

Each sequence auto-starts when the previous ends. `offset` overlaps/gaps.

## Animation primitives

### `interpolate(input, inRange, outRange, options?)`

```tsx
const opacity = interpolate(frame, [0, 30], [0, 1], {
  extrapolateLeft: 'clamp',
  extrapolateRight: 'clamp',
  easing: Easing.out(Easing.cubic), // from 'remotion' — optional
});
```

- Ranges must be strictly monotonic and equal length.
- **Default `extrapolate*` is `'extend'` — this will shoot past your endpoints.** Always pass `'clamp'` unless you explicitly want extrapolation.
- Multi-point: `interpolate(frame, [0, 30, 60, 90], [0, 1, 1, 0])` — fade in, hold, fade out.
- `Easing` presets: `Easing.linear`, `Easing.ease`, `Easing.bezier(a,b,c,d)`, `Easing.in/out/inOut(fn)`, `Easing.bounce`, `Easing.elastic(n)`, `Easing.cubic`, `Easing.poly(n)`, `Easing.sin`, `Easing.exp`, `Easing.circle`, `Easing.back(s)`.

### `spring({frame, fps, config?, durationInFrames?, delay?, from?, to?})`

Physics-based easing. Returns a number animating from `from` (default 0) to `to` (default 1).

```tsx
const scale = spring({
  frame,
  fps,
  config: {damping: 12, mass: 1, stiffness: 100},
  durationInFrames: 30, // optional: compress the spring into this many frames
});
```

Lower `damping` = more bounce. Typical useful values: `damping: 10–20`.

### `random(seed: string | number | null): number`

Deterministic pseudo-random in [0, 1). Use this instead of `Math.random()` — otherwise every rendered frame differs.

```tsx
const jitter = random(`dot-${i}`) * 10;
```

### `measureSpring(config)` / `interpolateColors`

- `measureSpring({fps, config})` → frames until a spring settles.
- `interpolateColors(frame, inRange, ['#fff', '#000'])` → interpolate RGB/HSL/hex colors.

## Layout

### `<AbsoluteFill>`
`position: absolute; inset: 0; display: flex; flex-direction: column;`. Use this for every full-screen scene container.

## Media

### `<Img src>`
Remotion-aware image. Waits for load before advancing frames during render.

### `<Video src>` vs `<OffthreadVideo src>`
Both play video frames synced to the composition. **Prefer `<OffthreadVideo>` for mp4** — it decodes off-thread and is faster to render. Use `<Video>` if you need DOM playback behavior (e.g., in Studio interactions).

```tsx
<OffthreadVideo src={staticFile('clip.mp4')} startFrom={30} endAt={150} />
```

- `startFrom` / `endAt` — trim the source video (in source-video frames).
- Place inside a `<Sequence>` to time when it appears.

### `<Audio src>`
```tsx
<Audio src={staticFile('music.mp3')} volume={0.5} startFrom={0} />
```
`volume` can be a number or a function `(frame) => number` for fades.

### `staticFile(path: string): string`
Resolves a file in `public/`. Never prefix with `/public`. Never `import` media files.

```tsx
<Img src={staticFile('logo.png')} />
<Img src={staticFile('images/hero.jpg')} />  // subdirs ok
```

## Utility components

- `<Freeze frame={N}>` — freeze children at a given frame.
- `<Loop durationInFrames={N}>` — repeat children every N frames.
- `<Still>` — mark a composition as a single-frame image.

## TypeScript

`React.FC<Props>` for components. `defaultProps` on `<Composition>` must match the `Props` type exactly. When using `schema={z.object(...)}`, the inferred type must also match.
