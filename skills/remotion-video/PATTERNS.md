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

## Audio-reactive scale (using an AudioContext analysis done ahead of time)

Run `@remotion/media-utils`'s `getAudioData()` + `visualizeAudio()` server-side or in a `calculateMetadata`; pass peaks as props and map peak-per-frame to scale:

```tsx
import {getAudioDurationInSeconds} from '@remotion/media-utils';
// peaks: number[] length = durationInFrames
const amp = peaks[frame] ?? 0;
const scale = 1 + amp * 0.3;
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

## Subtitles / captions from a JSON

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

For Whisper-generated captions with word timings, see `@remotion/captions` + `@remotion/install-whisper-cpp`.

## Looping a clip shorter than the composition

```tsx
<Loop durationInFrames={60}>
  <Sparkle />
</Loop>
```
