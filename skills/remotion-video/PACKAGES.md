# `@remotion/*` package map

One-line reference for every package in the Remotion scope. Use it to pick the right install when a user describes a feature.

| Package | Use |
|---|---|
| `remotion` | Core runtime: `<Composition>`, `<Sequence>`, hooks, `interpolate`, `spring`, `random`, `<Audio>`, `<OffthreadVideo>`, `<Img>`, `staticFile`, `delayRender`. |
| `@remotion/cli` | CLI runtime (`remotion render`, `remotion studio`, `remotion still`, `remotion lambda *`). |
| `@remotion/renderer` | Programmatic render API (`renderMedia`, `selectComposition`, `renderStill`). |
| `@remotion/bundler` | Webpack bundle helper for `@remotion/renderer` (`bundle({entryPoint})`). |
| `@remotion/lambda` | AWS serverless renders (`renderMediaOnLambda`, `getRenderProgress`). |
| `@remotion/cloudrun` | GCP renders. **Alpha, not actively developed — prefer Lambda.** |
| `@remotion/player` | Embed a `<Player>` in a regular React app for previews/UGC tools. |
| `@remotion/media` | Newer `<Video>` implementation + metadata helpers. Worth adopting for new projects. |
| `@remotion/media-utils` | `getAudioData`, `useAudioData`, `visualizeAudio`, `getAudioDurationInSeconds`, `getVideoMetadata`. |
| `@remotion/transitions` | `<TransitionSeries>` + presentations (`fade`, `slide`, `wipe`, `flip`, `clockWipe`, `iris`, `none`) and timings (`linearTiming`, `springTiming`). |
| `@remotion/captions` | Caption parsing/formatting: `parseSrt`, `createTikTokStyleCaptions`, types for Whisper output. |
| `@remotion/install-whisper-cpp` | Install and run whisper.cpp locally to generate word-timed captions. |
| `@remotion/google-fonts` | `loadFont()` per-family (`@remotion/google-fonts/Inter`) — handles `delayRender` internally. |
| `@remotion/tailwind-v4` | Tailwind v4 integration. (Older `@remotion/tailwind` is for v3.) |
| `@remotion/shapes` | SVG primitives (`<Triangle>`, `<Star>`, `<Pie>`, etc.). |
| `@remotion/skia` | `@shopify/react-native-skia` renderer (high-perf 2D). |
| `@remotion/three` | `react-three-fiber` integration for 3D scenes. |
| `@remotion/zod-types` | Zod helpers that produce richer Studio UI: `zColor()`, `zTextarea()`, etc. |
| `@remotion/paths` | SVG path utilities (`getLength`, `getPointAtLength`, path math). |
| `@remotion/noise` | Perlin / simplex noise helpers. |
| `@remotion/layout-utils` | Text measurement (`measureText`, `fitText`). |
| `@remotion/sfx` | Built-in sound effects library (v4.0.429+). Check this before sourcing external SFX. |
| `@remotion/motion-blur` | `<CameraMotionBlur>` and `<Trail>` components for motion blur effects. |
| `@remotion/animation-utils` | `makeTransform()` for type-safe composable CSS transforms. |
| `@remotion/animated-emoji` | Animated emoji components. |
| `@remotion/webcodecs` | Browser-side video conversion using WebCodecs. |
| `@remotion/media-parser` | Low-level container/codec parsing (being succeeded by Mediabunny). |
| `@remotion/compositor-*` | Platform-specific Rust compositor binaries (installed automatically — you should not depend on these directly). |

When in doubt, check https://www.remotion.dev/docs/ — new helper packages land frequently.
