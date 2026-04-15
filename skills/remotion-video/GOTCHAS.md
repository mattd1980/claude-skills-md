# Remotion gotchas

The top things that waste time when writing Remotion code. Check here first when something's off.

## Animation

### `setTimeout` / `setInterval` / `requestAnimationFrame` do nothing meaningful

Remotion renders frame-by-frame offline; there is no wall clock. These APIs don't fire in the render process. Drive every animated value from `useCurrentFrame()`.

### CSS `transition` and `animation` break rendering

Each frame is a fresh render — CSS transitions have no previous state to transition from. Compute the current value from `frame` and apply it as an inline style or transform.

### `interpolate` default extrapolation shoots past endpoints

```tsx
// BAD: opacity can exceed 1 or go negative
interpolate(frame, [0, 30], [0, 1])

// GOOD
interpolate(frame, [0, 30], [0, 1], {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'})
```

### `interpolate` ranges must be strictly monotonic

`[0, 30, 30, 60]` throws. Use `[0, 29, 30, 60]` or similar.

### Spring that "doesn't end" — it's asymptotic

`spring()` approaches but never quite reaches `to`. For deterministic endpoints use `durationInFrames` to compress the spring, or clamp with `Math.min(1, spring(...))`.

## Media

### Raw `<video>`, `<audio>`, `<img>` silently misbehave

Use `<Video>` / `<OffthreadVideo>`, `<Audio>`, `<Img>` from `remotion`. Native tags don't participate in Remotion's frame waiting or audio mixing.

### `<OffthreadVideo>` vs `<Video>`

`<OffthreadVideo>` decodes on a separate thread — faster and more stable for MP4. Prefer it. Use `<Video>` only if you specifically need DOM `<video>` playback semantics in Studio.

### `staticFile` paths are relative to `public/`

```tsx
staticFile('logo.png')            // public/logo.png  ✅
staticFile('/public/logo.png')    // ❌ breaks
staticFile('../assets/logo.png')  // ❌ escapes public/
import logo from './logo.png';    // ❌ don't import media
```

### Assets added to `public/` while Studio is running may not appear

Restart Studio, or bust the Remotion cache: delete `node_modules/.cache/remotion`.

### Video `trimBefore` / `trimAfter` are in source-video frames at source fps

Not composition frames. If your source is 24fps and the composition is 30fps, `trimBefore={30}` trims 30 frames of the source (1.25s), not 1s of the composition.

The old names `startFrom` / `endAt` still work but are **deprecated since 4.0.319**. If you see them in existing code, rename on touch.

## Randomness / determinism

### `Math.random()` changes per frame

Every frame is a fresh render with a fresh JS context (or at least fresh component evaluations). Use `random(seed)` from `remotion` with a stable seed so the same frame always returns the same value.

### Random-per-item patterns

```tsx
items.map((item, i) => {
  const jitter = random(`${item.id}-jitter`) * 10; // stable per item
  // ...
});
```

## SSR / bundling

### `window`, `document`, `localStorage` crash the bundler

Components run under SSR during bundling to extract metadata. Guard top-level usage:

```tsx
if (typeof window !== 'undefined') {
  // safe
}

// or defer to useEffect (which doesn't run during render-phase, but is safe at runtime)
```

### Dynamic imports of node-only modules

Remotion bundles with webpack — node built-ins aren't available to composition code. Keep `fs`, `path`, etc. out of compositions. Do file work in `calculateMetadata` or ahead of time and pass results as props.

### Vite is not supported

Remotion uses its own webpack configuration and there is no official Vite story. If a user asks, the answer is "run Remotion with its own bundler; Vite can still power the surrounding app that embeds `<Player>`."

### Async work without `delayRender` captures empty frames

If you `fetch()` JSON or load a custom `FontFace` inside a component, the renderer takes the screenshot before the promise resolves. Wrap async work in `delayRender()` and call `continueRender(handle)` when done (or `cancelRender(err)` on failure). Default timeout is 30 s — bump with `delayRender('msg', {timeoutInMilliseconds: 60000})` or `Config.setDelayRenderTimeoutInMilliseconds(...)`. Missing `continueRender` = hung render.

### Custom fonts loaded via `<link>` render as fallback for the first frames

The browser loads fonts asynchronously, and the first Remotion frames will already be captured before the font arrives — so they render in the fallback font. Use `@remotion/google-fonts` (handles `delayRender` internally) or wrap `new FontFace(...).load()` in your own `delayRender` / `continueRender`.

## Props

### `defaultProps` must serialize to JSON

No functions, Dates (will be stringified), class instances. Use primitives/arrays/plain objects. If you pass via `--props`, the JSON has to round-trip.

### Schema + defaultProps mismatch = bundler error

If you use `schema={z.object({...})}`, `defaultProps` must satisfy it. Easiest pattern: `defaultProps: z.infer<typeof schema> = {...}` to get a TS error early.

## Duration

### Last rendered frame is `durationInFrames - 1`

A 30-frame composition renders frames 0..29. If your animation expects to be fully settled "at the end", target `durationInFrames - 1` as the endpoint, not `durationInFrames`.

### `durationInFrames` must be integer ≥ 1

Decimal or 0 throws. When computing from seconds: `Math.round(seconds * fps)`.

## Performance

### Lots of DOM nodes = slow

Remotion renders real DOM per frame. For 1000+ particles, consider `<Canvas>` (2D canvas), `@remotion/skia`, or `@remotion/three`.

### Large images = huge memory

A 4K PNG per composition eats RAM fast across parallel frame renders. Downscale assets to match the composition size, or lower `--concurrency`.

### Slow renders: try `--image-format=jpeg`

Default for new projects is often PNG. JPEG is materially faster when you don't need alpha.

## Studio quirks

### Props panel only appears with a Zod `schema`

No schema = no UI inputs. Add even a minimal schema for any composition you want to tweak interactively.

### Refresh needed after changing `Root.tsx` `<Composition>` ids

Studio's sidebar caches the composition list. Hard-refresh the browser if a new composition doesn't appear.

## Licensing

Remotion charges for-profit organisations with **more than 3 employees**. Flag this to the user for any commercial use — solo/hobby and ≤3-employee company use is free. Link: https://www.remotion.dev/docs/license.
