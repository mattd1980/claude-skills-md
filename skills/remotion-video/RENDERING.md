# Rendering Remotion projects

## Studio (preview + editor)

```bash
npx remotion studio
# alias: npx remotion preview
# default port 3000; override with --port
```

Opens the local editor: timeline scrubber, props panel (driven by your Zod schema), re-renders on file save.

## CLI render

```bash
npx remotion render [entry-point] <composition-id> [output]
```

- `entry-point` defaults to `src/index.ts`; omit unless non-standard.
- `composition-id` is the `id` prop on `<Composition>` in `Root.tsx`.
- `output` path extension determines the codec if `--codec` is omitted.

### Common flags

| Flag | Purpose |
|---|---|
| `--codec h264` | `h264` (default), `h265`, `vp8`, `vp9`, `av1`, `prores`, `gif`, `mp3`, `aac`, `wav`. |
| `--props='{"title":"Hi"}'` | JSON string or path to a `.json` file (`--props=./props.json`). |
| `--image-format jpeg` | `jpeg` (faster) or `png` (slower, supports alpha). |
| `--jpeg-quality 80` | JPEG quality 0–100. Renamed from `--quality` in v4.0. |
| `--concurrency 8` | Parallel frame rendering. Defaults to half your CPU. |
| `--scale 2` | 2× resolution. |
| `--crf 18` | Quality (lower = better; 18 is near-visually-lossless for h264). |
| `--frames 30-90` | Render only a range. `--frames=42` for a single frame. |
| `--hardware-acceleration` | `disable` (default), `if-possible`, `required`. GPU-accelerated encoding (4.0.228+). |
| `--overwrite` | Overwrite existing output. |
| `--log=verbose` | Debug renderer issues. |
| `--quiet` | CI-friendly output. |

**Removed in v4:** `--ffmpeg-executable` and `--ffprobe-executable` — Remotion now bundles its own ffmpeg. Porting from v3? Drop these flags.

### Still image

```bash
npx remotion still <composition-id> out.png --frame=60
```

## Passing props

Three ways to get props into a composition:

1. **`defaultProps`** on `<Composition>` — used by Studio when no other source.
2. **CLI `--props`** — overrides defaults for one render.
3. **Programmatic `inputProps`** when using `renderMedia()` or Lambda.

Validate with a Zod schema for automatic Studio UI + type safety:

```tsx
import {z} from 'zod';

const schema = z.object({
  title: z.string(),
  color: z.string(),
  showLogo: z.boolean(),
});

<Composition
  id="MyVideo"
  component={MyVideo}
  schema={schema}
  defaultProps={{title: 'Hi', color: '#f00', showLogo: true}}
  durationInFrames={150}
  fps={30}
  width={1920}
  height={1080}
/>
```

The component's props type should match `z.infer<typeof schema>`.

For richer Studio input controls, import from `@remotion/zod-types`:

```ts
import {zColor, zTextarea} from '@remotion/zod-types';

const schema = z.object({
  background: zColor(),     // Studio renders a color picker
  caption: zTextarea(),     // Studio renders a multi-line textarea
});
```

## `calculateMetadata` — dynamic duration/dimensions from props

Can override any of `durationInFrames`, `width`, `height`, `fps`, and merge into `defaultProps`. Use when duration depends on input (e.g., matching an audio clip length):

```tsx
import {getAudioDurationInSeconds} from '@remotion/media-utils';
import {staticFile} from 'remotion';

<Composition
  id="Audiogram"
  component={Audiogram}
  fps={30}
  width={1080}
  height={1920}
  defaultProps={{audio: 'narration.mp3'}}
  durationInFrames={1}  // placeholder
  calculateMetadata={async ({props}) => {
    const seconds = await getAudioDurationInSeconds(staticFile(props.audio));
    return {durationInFrames: Math.floor(seconds * 30)};
  }}
/>
```

## Programmatic render (`@remotion/renderer`)

```ts
import {bundle} from '@remotion/bundler';
import {renderMedia, selectComposition} from '@remotion/renderer';
import path from 'node:path';

const serveUrl = await bundle({entryPoint: path.resolve('src/index.ts')});
const composition = await selectComposition({
  serveUrl,
  id: 'MyVideo',
  inputProps: {title: 'Hi'},
});
await renderMedia({
  serveUrl,
  composition,
  codec: 'h264',
  outputLocation: 'out/video.mp4',
  inputProps: {title: 'Hi'},
});
```

Use this for: batch pipelines, queue workers, embedded in a Node backend.

### Rust-accelerated rendering

Remotion 4.x moved the compositor hot path to a Rust binary (`@remotion/compositor-*` platform packages). Much of the perf tuning needed in v3 (GL backends, swiftshader flags) is now automatic. If you still hit issues, `--hardware-acceleration=if-possible` is usually the knob to reach for first.

## Embedding in a React app: `@remotion/player`

For live previews in a React UI (dashboards, UGC editors, SaaS landing pages):

```tsx
import {Player} from '@remotion/player';
import {Showcase} from './Showcase';

<Player
  component={Showcase}
  inputProps={{headline: 'Hi'}}
  durationInFrames={195}
  compositionWidth={1920}
  compositionHeight={1080}
  fps={30}
  style={{width: '100%'}}
  controls
/>
```

`<Player>` is a normal React component — it runs in the browser, no rendering backend required. Pair with `renderMediaOnLambda` to export what the user previews. Docs: https://www.remotion.dev/docs/player

## Lambda rendering (`@remotion/lambda`)

For high concurrency or serverless. Function names follow the convention `remotion-render-<version>-mem<MB>mb-disk<MB>mb-<timeout>sec` (e.g. `remotion-render-4-0-420-mem2048mb-disk2048mb-120sec`). You pass this as `functionName` — don't confuse it with `serveUrl` (the site URL).

One-time setup:

```bash
npx remotion lambda policies user      # show required IAM policy
npx remotion lambda policies role      # role policy
npx remotion lambda functions deploy   # deploy render function
npx remotion lambda sites create src/index.ts --site-name=my-video
```

Then render:

```ts
import {renderMediaOnLambda, getRenderProgress} from '@remotion/lambda/client';

const {renderId, bucketName} = await renderMediaOnLambda({
  region: 'us-east-1',
  functionName: 'remotion-render-...',
  serveUrl: 'https://remotionlambda-.../sites/my-video/index.html',
  composition: 'MyVideo',
  inputProps: {title: 'Hi'},
  codec: 'h264',
});

// Poll progress:
const progress = await getRenderProgress({renderId, bucketName, functionName, region});
```

Output lands in S3. Trade-off: fast for many concurrent renders, more moving parts than local.

## Cloud Run (`@remotion/cloudrun`)

> **Alpha, not actively developed** as of April 2026 (https://www.remotion.dev/docs/cloudrun). Prefer Lambda for production. Kept here because some GCP-only orgs still need it.

Similar to Lambda but on GCP. Setup: `npx remotion cloudrun services deploy`, then `renderMediaOnCloudrun`.

## CI / headless environments

- On Linux servers, Remotion installs Chromium automatically but needs system libs. For Debian/Ubuntu the error messages list the missing packages; typical set: `libnss3 libatk1.0-0 libatk-bridge2.0-0 libxkbcommon0 libxcomposite1 libxdamage1 libxfixes3 libxrandr2 libgbm1 libasound2`.
- Use `--concurrency=1` if you hit OOM on small CI runners.
- Cache `node_modules/.cache/remotion` between runs to speed up bundling.

## Output troubleshooting

| Symptom | Fix |
|---|---|
| Audio desynced | Using raw `<audio>` — switch to `<Audio>`. |
| Video black for first frames | Raw `<video>` tag; switch to `<OffthreadVideo>`. |
| Asset 404 | Using `import` for a media file; move to `public/` and use `staticFile()`. |
| Animation only moves in Studio, static in render | Using `setTimeout`/CSS animation; rewrite off `useCurrentFrame()`. |
| Different randomness each render | `Math.random()`; switch to `random(seed)`. |
| Output missing last frame | Off-by-one — remember last frame is `durationInFrames - 1`. |
