# Remotion setup & project structure

## Scaffold

```bash
npx create-video@latest <project-name>
# or: npm create video@latest / pnpm create video / bun create video / yarn create video
```

Requires Node 16+ (Node 20+ recommended for Remotion 4.x). Chromium is auto-installed by `@remotion/renderer` on first render.

## Templates

Select in the interactive prompt or via CLI flag.

| Template | Use when |
|---|---|
| `hello-world` | Default. TypeScript. Start here unless the user asks otherwise. |
| `hello-world-javascript` | User insists on JS. |
| `blank` | Experienced user wants minimal scaffolding. |
| `empty` | Absolute minimum — you'll build everything. |
| `still` | Generating images only (no animation). |
| `tailwind` | Tailwind CSS pre-wired. |
| `next` / `next-pages-dir` | Embedding Remotion in a Next.js app (App Router or Pages Router). |
| `remix` | Remix integration. |
| `react-router` | Plain React Router app. |
| `three` | react-three-fiber / 3D scenes. |
| `skia` | `@shopify/react-native-skia` rendering. |
| `audiogram` | Audio waveform + subtitle videos (podcasts, clips). |
| `tts-google` / `tts-azure` | Text-to-speech pipelines. |
| `overlay` | Next.js visual editor starter (timeline-based editor). |

## Project layout (default template)

```
<project>/
├── src/
│   ├── index.ts           // registerRoot(RemotionRoot)
│   ├── Root.tsx           // <Composition /> registrations — the "video registry"
│   └── Composition.tsx    // example scene component
├── public/                // static assets — load via staticFile()
├── remotion.config.ts     // codec, concurrency, image format defaults
├── package.json
└── tsconfig.json
```

### `src/index.ts` — entry point

```ts
import {registerRoot} from 'remotion';
import {RemotionRoot} from './Root';

registerRoot(RemotionRoot);
```

### `src/Root.tsx` — all compositions registered here

One `<Composition>` per renderable video. The `id` is what you pass to `remotion render`.

```tsx
import {Composition} from 'remotion';
import {MyScene} from './MyScene';

export const RemotionRoot: React.FC = () => (
  <>
    <Composition
      id="MyScene"
      component={MyScene}
      durationInFrames={150}
      fps={30}
      width={1920}
      height={1080}
      defaultProps={{title: 'Hello'}}
    />
    {/* More <Composition> entries as needed */}
  </>
);
```

### Default dimensions

Templates default to **1920×1080 @ 30fps, 150 frames (5s)**. Common overrides:

| Target | width × height | fps | notes |
|---|---|---|---|
| 1080p YouTube | 1920×1080 | 30 or 60 | |
| 4K | 3840×2160 | 30 | slower renders, higher RAM |
| Vertical (Shorts/TikTok/Reels) | 1080×1920 | 30 | |
| Square (Instagram feed) | 1080×1080 | 30 | |

## `remotion.config.ts`

Build-wide defaults. Common settings:

```ts
import {Config} from '@remotion/cli/config';

Config.setVideoImageFormat('jpeg');   // faster than 'png' for most videos
Config.setConcurrency(8);              // parallel frame rendering
Config.setCodec('h264');               // default render codec
Config.setPixelFormat('yuv420p');      // broad compatibility
Config.overrideWebpackConfig((c) => c); // escape hatch
```

## Package scripts (typical)

```json
{
  "scripts": {
    "start": "remotion studio",
    "build": "remotion render",
    "upgrade": "remotion upgrade"
  }
}
```

## Licensing — flag on commercial work

Remotion uses a custom company license. Companies with 4+ employees need a paid license. Mention this when the user describes commercial use and link https://www.remotion.dev/docs/license.
