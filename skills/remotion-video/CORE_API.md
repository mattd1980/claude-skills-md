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

### `<Video>` / `<OffthreadVideo>` (and the new `@remotion/media` `<Video>`)

Three options as of Remotion 4.x:

- **`<OffthreadVideo>`** from `'remotion'` — decodes off-thread, fastest for MP4 renders. **Default choice for rendering.**
- **`<Video>`** from `'remotion'` — uses a DOM `<video>` element; use when you need native playback semantics in Studio/`<Player>`.
- **`<Video>`** from `@remotion/media` — newer, positioned to eventually replace the DOM-based `<Video>`. Worth using if a project already depends on `@remotion/media`.

```tsx
<OffthreadVideo src={staticFile('clip.mp4')} trimBefore={30} trimAfter={150} />
```

- `trimBefore` / `trimAfter` — trim the source video (in source-video frames).
- Legacy names `startFrom` / `endAt` still work but are **deprecated since 4.0.319**. Always write `trimBefore` / `trimAfter` in new code.
- Place inside a `<Sequence>` to time when it appears.

### `<Audio src>`
```tsx
<Audio src={staticFile('music.mp3')} volume={0.5} trimBefore={0} />
```
`volume` can be a number or a function `(frame) => number` for fades. Same `trimBefore` / `trimAfter` rename applies.

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

## Async work (`delayRender` / `continueRender`)

The renderer snapshots each frame as soon as React commits. Any async work — font loading, fetching JSON, waiting for image decode — must block the snapshot with `delayRender()`:

```tsx
import {delayRender, continueRender} from 'remotion';

const [handle] = useState(() => delayRender('Loading caption data'));
const [captions, setCaptions] = useState<Caption[]>([]);

useEffect(() => {
  fetch(staticFile('captions.json'))
    .then((r) => r.json())
    .then((data) => {
      setCaptions(data);
      continueRender(handle);
    })
    .catch((err) => cancelRender(err));
}, [handle]);
```

- `delayRender(label?)` returns a handle; the render waits until every outstanding handle is passed to `continueRender(handle)` or `cancelRender(err)`.
- Default timeout is 30 s. Override via `delayRender('msg', {timeoutInMilliseconds: 60000})` or `Config.setDelayRenderTimeoutInMilliseconds(...)` in `remotion.config.ts`.
- The label shows up in error messages — make it specific.
- If you forget to call `continueRender`, renders hang and time out.

## `calculateMetadata`

Dynamic per-composition metadata computed from props. Can override `durationInFrames`, `width`, `height`, `fps`, and merge into `defaultProps`. See `RENDERING.md#calculatemetadata--dynamic-durationdimensions-from-props`.

## `measureSpring` vs `springTiming`

- `measureSpring({fps, config})` from `'remotion'` → number of frames until a spring settles. Handy when you need to size a `<Sequence>` to fit a spring.
- `springTiming({config, durationInFrames?})` from `@remotion/transitions` → the same concept, but returns a timing object for `<TransitionSeries.Transition>`.

## TypeScript

`React.FC<Props>` for components. `defaultProps` on `<Composition>` must match the `Props` type exactly. When using `schema={z.object(...)}`, the inferred type must also match.
