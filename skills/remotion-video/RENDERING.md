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
| `--codec h264` | `h264` (default), `h265`, `vp8`, `vp9`, `prores`, `gif`, `mp3`, `aac`, `wav`. |
| `--props='{"title":"Hi"}'` | JSON string or path to a `.json` file (`--props=./props.json`). |
| `--image-format jpeg` | `jpeg` (faster) or `png` (slower, supports alpha). |
| `--concurrency 8` | Parallel frame rendering. Defaults to half your CPU. |
| `--scale 2` | 2× resolution. |
| `--crf 18` | Quality (lower = better; 18 is near-visually-lossless for h264). |
| `--frames 30-90` | Render only a range. `--frames 42` for a single frame. |
| `--overwrite` | Overwrite existing output. |
| `--log=verbose` | Debug renderer issues. |
| `--quiet` | CI-friendly output. |

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

## `calculateMetadata` — dynamic duration/dimensions from props

Use when duration depends on input (e.g., matching an audio clip length):

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

## Lambda rendering (`@remotion/lambda`)

For high concurrency or serverless. One-time setup:

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
