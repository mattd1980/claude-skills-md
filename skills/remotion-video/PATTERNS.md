# Remotion animation patterns

Copy-paste snippets for the most common video building blocks. All assume `frame = useCurrentFrame()` and `{fps} = useVideoConfig()`.

## Fade in

```tsx
const opacity = interpolate(frame, [0, 20], [0, 1], {
  extrapolateLeft: 'clamp',
  extrapolateRight: 'clamp',
});
```

## Fade in + out

```tsx
const opacity = interpolate(
  frame,
  [0, 20, durationInFrames - 20, durationInFrames],
  [0, 1, 1, 0],
  {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'}
);
```

## Slide in from the left

```tsx
const x = interpolate(frame, [0, 25], [-200, 0], {
  extrapolateLeft: 'clamp',
  extrapolateRight: 'clamp',
  easing: Easing.out(Easing.cubic),
});
// style={{transform: `translateX(${x}px)`}}
```

## Spring-in scale (pop)

```tsx
const scale = spring({frame, fps, config: {damping: 12}});
// style={{transform: `scale(${scale})`}}
```

## Staggered entrance (list of items)

```tsx
items.map((item, i) => {
  const start = i * 5; // 5-frame stagger
  const enter = spring({frame: frame - start, fps, config: {damping: 14}});
  return (
    <div key={item.id} style={{opacity: enter, transform: `translateY(${(1 - enter) * 30}px)`}}>
      {item.label}
    </div>
  );
});
```

## Typewriter text

```tsx
const chars = Math.floor(interpolate(frame, [0, 60], [0, text.length], {
  extrapolateLeft: 'clamp',
  extrapolateRight: 'clamp',
}));
const visible = text.slice(0, chars);
```

## Number count-up

```tsx
const value = Math.round(interpolate(frame, [0, 45], [0, 1_000_000], {
  extrapolateLeft: 'clamp',
  extrapolateRight: 'clamp',
  easing: Easing.out(Easing.cubic),
}));
// {value.toLocaleString()}
```

## Camera zoom / Ken Burns

```tsx
const progress = interpolate(frame, [0, durationInFrames], [0, 1]);
const scale = 1 + progress * 0.1;  // 10% zoom over the shot
const tx = progress * -50;          // pan left
// style={{transform: `scale(${scale}) translateX(${tx}px)`}}
```

## Parallax layers

```tsx
const bgX = interpolate(frame, [0, durationInFrames], [0, -100]);
const fgX = interpolate(frame, [0, durationInFrames], [0, -300]);
```

Wrap each layer in `<AbsoluteFill>` with its own transform.

## Looping rotation

```tsx
const rotation = (frame / fps) * 360 / 4; // 360° every 4 seconds
// style={{transform: `rotate(${rotation}deg)`}}
```

## Audio-reactive scale

Use `@remotion/media-utils` to analyse audio and drive any animated value from the current amplitude. Load audio data once with `delayRender`, then sample it per frame with `visualizeAudio`.

```tsx
import {useAudioData, visualizeAudio} from '@remotion/media-utils';
import {staticFile, useCurrentFrame, useVideoConfig} from 'remotion';

const audioSrc = staticFile('music.mp3');

export const AudioReactive: React.FC = () => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const audioData = useAudioData(audioSrc);       // null until loaded (uses delayRender internally)

  if (!audioData) return null;

  const visualization = visualizeAudio({
    fps,
    frame,
    audioData,
    numberOfSamples: 16,
  });                                              // number[] of amplitudes in [0, 1]

  const amp = visualization[0] ?? 0;
  const scale = 1 + amp * 0.6;

  return (
    <>
      <Audio src={audioSrc} />
      <div style={{transform: `scale(${scale})`}}>🔊</div>
    </>
  );
};
```

## Scene transitions (fade / slide between sequences)

Use `@remotion/transitions`:

```tsx
import {TransitionSeries, linearTiming} from '@remotion/transitions';
import {fade} from '@remotion/transitions/fade';

<TransitionSeries>
  <TransitionSeries.Sequence durationInFrames={60}><SceneA /></TransitionSeries.Sequence>
  <TransitionSeries.Transition presentation={fade()} timing={linearTiming({durationInFrames: 15})} />
  <TransitionSeries.Sequence durationInFrames={90}><SceneB /></TransitionSeries.Sequence>
</TransitionSeries>
```

Other presentations: `slide`, `wipe`, `flip`, `clockWipe`, `iris`, `none`.

## Background music with ducking under narration

```tsx
<Audio src={staticFile('music.mp3')} volume={(f) => (f > 60 && f < 180 ? 0.2 : 0.6)} />
<Sequence from={60} durationInFrames={120}>
  <Audio src={staticFile('narration.mp3')} />
</Sequence>
```

## Custom fonts (Google Fonts)

Never `<link>` to Google Fonts from HTML — it races the renderer. Use `@remotion/google-fonts`:

```tsx
import {loadFont} from '@remotion/google-fonts/Inter';

const {fontFamily} = loadFont();

export const Title: React.FC = () => (
  <h1 style={{fontFamily, fontWeight: 700}}>Hello</h1>
);
```

`loadFont()` handles `delayRender`/`continueRender` internally. Select weights/subsets: `loadFont('normal', {weights: ['400', '700'], subsets: ['latin']})`. For a custom `.woff2` in `public/`, wrap your own `FontFace.load()` in `delayRender`/`continueRender`.

## Subtitles / captions

### Simple JSON timeline

```tsx
import captions from './captions.json'; // [{from, durationInFrames, text}]

{captions.map((c, i) => (
  <Sequence key={i} from={c.from} durationInFrames={c.durationInFrames}>
    <AbsoluteFill style={{justifyContent: 'flex-end', alignItems: 'center', paddingBottom: 80}}>
      <span style={{color: 'white', fontSize: 48, background: 'rgba(0,0,0,0.6)', padding: '8px 16px'}}>
        {c.text}
      </span>
    </AbsoluteFill>
  </Sequence>
))}
```

### TikTok-style word-by-word with `@remotion/captions`

For Whisper-generated word timings:

```tsx
import {createTikTokStyleCaptions, type Caption} from '@remotion/captions';

// captions: Caption[] from Whisper, e.g. [{text, startMs, endMs, timestampMs, confidence}, ...]
const {pages} = createTikTokStyleCaptions({
  captions,
  combineTokensWithinMilliseconds: 1200,
});

// Each page is a group of words shown together.
pages.map((page, i) => {
  const fromFrame = Math.round((page.startMs / 1000) * fps);
  const duration = Math.round(((page.tokens.at(-1)!.toMs - page.startMs) / 1000) * fps);
  return (
    <Sequence key={i} from={fromFrame} durationInFrames={duration}>
      {/* render page.tokens with per-word highlight based on useCurrentFrame() */}
    </Sequence>
  );
});
```

Pair with `@remotion/install-whisper-cpp` to generate the captions file locally. The `tiktok` starter template wires all of this up end-to-end.

## Looping a clip shorter than the composition

```tsx
<Loop durationInFrames={60}>
  <Sparkle />
</Loop>
```

## Full end-to-end example

A complete composition combining titles, a video clip, background music, a transition, and captions. Render it with `npx remotion render src/index.ts Showcase out.mp4`.

```tsx
// src/Showcase.tsx
import {
  AbsoluteFill, Audio, Img, OffthreadVideo, Sequence, interpolate, spring,
  staticFile, useCurrentFrame, useVideoConfig,
} from 'remotion';
import {TransitionSeries, linearTiming} from '@remotion/transitions';
import {fade} from '@remotion/transitions/fade';
import {loadFont} from '@remotion/google-fonts/Inter';

const {fontFamily} = loadFont();

const Title: React.FC<{text: string}> = ({text}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const scale = spring({frame, fps, config: {damping: 12}});
  const opacity = interpolate(frame, [0, 15], [0, 1], {
    extrapolateLeft: 'clamp', extrapolateRight: 'clamp',
  });
  return (
    <AbsoluteFill style={{background: '#0a0a0a', justifyContent: 'center', alignItems: 'center'}}>
      <h1 style={{fontFamily, color: 'white', fontSize: 120, opacity, transform: `scale(${scale})`}}>
        {text}
      </h1>
    </AbsoluteFill>
  );
};

const Clip: React.FC = () => (
  <AbsoluteFill>
    <OffthreadVideo src={staticFile('clip.mp4')} trimBefore={0} trimAfter={120} />
  </AbsoluteFill>
);

export const Showcase: React.FC<{headline: string}> = ({headline}) => (
  <AbsoluteFill>
    <Audio src={staticFile('music.mp3')} volume={(f) => (f > 60 && f < 180 ? 0.25 : 0.6)} />
    <TransitionSeries>
      <TransitionSeries.Sequence durationInFrames={60}>
        <Title text={headline} />
      </TransitionSeries.Sequence>
      <TransitionSeries.Transition presentation={fade()} timing={linearTiming({durationInFrames: 15})} />
      <TransitionSeries.Sequence durationInFrames={120}>
        <Clip />
      </TransitionSeries.Sequence>
    </TransitionSeries>
  </AbsoluteFill>
);
```

```tsx
// src/Root.tsx
import {Composition} from 'remotion';
import {z} from 'zod';
import {Showcase} from './Showcase';

const schema = z.object({headline: z.string()});

export const RemotionRoot: React.FC = () => (
  <Composition
    id="Showcase"
    component={Showcase}
    schema={schema}
    defaultProps={{headline: 'Ship it'}}
    durationInFrames={195}  // 60 title + 120 clip + 15 overlap
    fps={30}
    width={1920}
    height={1080}
  />
);
```

