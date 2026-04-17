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

## Title card (enter / hold / exit)

Rule of thumb at 30fps: enter 12–18 frames, hold 45–60 frames, exit 12–18 frames. Total ≈ 2.5s — the typical title-card duration in a demo video.

```tsx
const enter = spring({frame, fps, config: {damping: 12}});
const exit = interpolate(frame, [durationInFrames - 18, durationInFrames], [1, 0], {
  extrapolateLeft: 'clamp',
  extrapolateRight: 'clamp',
});
const opacity = Math.min(enter, exit);
// style={{opacity, transform: `scale(${enter})`}}
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

---

## Advanced animations

Techniques beyond spring/interpolate. Each entry: what it is, when to reach for it, complete snippet, gotchas.

### Particle system

Deterministic particles using `random(seed)`. Good for energy, celebration, ambient texture.

```tsx
import {AbsoluteFill, random, useCurrentFrame, useVideoConfig} from 'remotion';

const PARTICLE_COUNT = 80;

export const Particles: React.FC<{seed?: string}> = ({seed = 'p'}) => {
  const frame = useCurrentFrame();
  const {width, height, fps} = useVideoConfig();

  const particles = new Array(PARTICLE_COUNT).fill(0).map((_, i) => ({
    x: random(`${seed}-x-${i}`) * width,
    baseY: random(`${seed}-y-${i}`) * height,
    size: 2 + random(`${seed}-s-${i}`) * 4,
    speed: 0.3 + random(`${seed}-sp-${i}`) * 1.2,
    opacity: 0.15 + random(`${seed}-o-${i}`) * 0.35,
    hue: random(`${seed}-h-${i}`) * 60 + 220,
  }));

  return (
    <AbsoluteFill>
      {particles.map((p, i) => {
        const y = (p.baseY - frame * p.speed) % height;
        const adjustedY = y < 0 ? y + height : y;
        return (
          <div
            key={i}
            style={{
              position: 'absolute',
              left: p.x,
              top: adjustedY,
              width: p.size,
              height: p.size,
              borderRadius: '50%',
              background: `hsla(${p.hue}, 70%, 70%, ${p.opacity})`,
            }}
          />
        );
      })}
    </AbsoluteFill>
  );
};
```

**Performance:** >200 DOM particles gets slow during render. For heavy particle work, use a `<canvas>` element (draw in `useEffect` keyed to `frame`) or `@remotion/three` for GPU-accelerated particles.

### 3D perspective transforms (CSS-only)

No Three.js needed. Full CSS 3D works in Remotion because it renders in headless Chrome.

**Card flip:**

```tsx
const progress = spring({frame, fps, config: {damping: 14}});
const rotateY = interpolate(progress, [0, 1], [0, 180]);

<div style={{perspective: 1000}}>
  {/* Front face */}
  <AbsoluteFill style={{
    backfaceVisibility: 'hidden',
    transform: `rotateY(${rotateY}deg)`,
  }}>
    <FrontContent />
  </AbsoluteFill>
  {/* Back face — starts rotated 180deg so it's hidden initially */}
  <AbsoluteFill style={{
    backfaceVisibility: 'hidden',
    transform: `rotateY(${rotateY + 180}deg)`,
  }}>
    <BackContent />
  </AbsoluteFill>
</div>
```

**Tilt entrance:**

```tsx
const enter = spring({frame, fps, config: {damping: 12}});
const tiltX = interpolate(enter, [0, 1], [25, 0]);
const tiltZ = interpolate(enter, [0, 1], [-5, 0]);

<div style={{perspective: 1200}}>
  <div style={{
    transform: `rotateX(${tiltX}deg) rotateZ(${tiltZ}deg)`,
    opacity: enter,
  }}>
    {children}
  </div>
</div>
```

**Depth parallax (multi-layer):**

```tsx
const scroll = interpolate(frame, [0, durationInFrames], [0, -300]);

<div style={{perspective: 800, overflow: 'hidden'}}>
  <div style={{transform: `translateZ(-200px) translateY(${scroll * 0.3}px) scale(1.5)`}}>
    <BackgroundLayer />
  </div>
  <div style={{transform: `translateZ(0px) translateY(${scroll}px)`}}>
    <ForegroundLayer />
  </div>
</div>
```

**Gotcha:** Transform order matters in CSS — `rotateX` then `translateZ` is different from `translateZ` then `rotateX`. Use `makeTransform()` from `@remotion/animation-utils` for type-safe composition if the chain gets complex.

**Gotcha:** SVG elements default to **top-left** transform origin. Always set `transformBox: 'fill-box'` and `transformOrigin: 'center center'` on animated SVG elements.

### SVG path drawing (line-draw effect)

Using `@remotion/paths`:

```tsx
import {getLength} from '@remotion/paths';
import {interpolate, useCurrentFrame} from 'remotion';

const path = 'M 10 80 C 40 10, 65 10, 95 80 S 150 150, 180 80';
const length = getLength(path);

export const LineDrawing: React.FC = () => {
  const frame = useCurrentFrame();
  const drawn = interpolate(frame, [0, 60], [length, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <svg width={200} height={200} viewBox="0 0 200 200">
      <path
        d={path}
        fill="none"
        stroke="white"
        strokeWidth={3}
        strokeLinecap="round"
        strokeDasharray={length}
        strokeDashoffset={drawn}
      />
    </svg>
  );
};
```

**Animate along a path** — move an element along an SVG curve:

```tsx
import {getLength, getPointAtLength} from '@remotion/paths';

const totalLength = getLength(path);
const traveled = interpolate(frame, [0, 90], [0, totalLength], {
  extrapolateLeft: 'clamp',
  extrapolateRight: 'clamp',
});
const {x, y} = getPointAtLength(path, traveled);
// style={{transform: `translate(${x}px, ${y}px)`}}
```

### Path morphing

Animate between two SVG path shapes:

```tsx
import {interpolatePath} from '@remotion/paths';
import {makeStarPath} from '@remotion/shapes';
import {makeCirclePath} from '@remotion/shapes';
import {spring, useCurrentFrame, useVideoConfig} from 'remotion';

export const Morph: React.FC = () => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const progress = spring({frame, fps, config: {damping: 14}});

  const starPath = makeStarPath({innerRadius: 40, outerRadius: 80, points: 5});
  const circlePath = makeCirclePath({radius: 60});
  const d = interpolatePath(progress, starPath, circlePath);

  return (
    <svg width={200} height={200} viewBox="-100 -100 200 200">
      <path d={d} fill="rgba(139, 92, 246, 0.8)" />
    </svg>
  );
};
```

Both paths should have a similar number of commands for smooth morphing. `@remotion/shapes` generates well-matched paths. For arbitrary SVGs, the morph may produce unexpected intermediate shapes — test in Studio.

### Noise-driven organic motion

Using `@remotion/noise` for floating, breathing, and procedural effects:

```tsx
import {noise2D} from '@remotion/noise';
import {useCurrentFrame, useVideoConfig} from 'remotion';

export const FloatingElement: React.FC<{children: React.ReactNode}> = ({children}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const t = frame / fps;

  // Gentle wandering — low frequency (0.5), small amplitude (20px)
  const dx = noise2D('drift-x', t * 0.5, 0) * 20;
  const dy = noise2D('drift-y', 0, t * 0.5) * 15;
  const rotate = noise2D('rot', t * 0.3, 0.5) * 3; // subtle ±3° wobble

  return (
    <div style={{transform: `translate(${dx}px, ${dy}px) rotate(${rotate}deg)`}}>
      {children}
    </div>
  );
};
```

**Use cases:**
- **Floating background elements** — wrap each in `FloatingElement` with different seeds.
- **Camera shake** — apply noise to the entire scene container with higher frequency/amplitude.
- **Procedural color shift** — `noise3D('color', x, y, frame / fps)` mapped to hue offset.
- **Organic scaling** (breathing) — `1 + noise2D('breath', t * 0.8, 0) * 0.03`.

**Tuning:** lower first argument to `noise2D` = smoother motion. `t * 0.3` is very gentle; `t * 2` is jittery. The amplitude multiplier (20px, 15px) controls range.

### Motion blur

Using `@remotion/motion-blur`:

```tsx
import {CameraMotionBlur} from '@remotion/motion-blur';

<CameraMotionBlur shutterAngle={180} samples={10}>
  <AbsoluteFill>
    <FastMovingContent />
  </AbsoluteFill>
</CameraMotionBlur>
```

- `shutterAngle`: 0–360. 180 = cinema standard. 360 = maximum blur.
- `samples`: more = smoother but **slower render and color-destructive**. Keep 5–10.
- Children **must** use `<AbsoluteFill>` (absolute positioning required).
- Use for: fast pans, zoom transitions, speed ramps. **Skip for static/slow content** — expensive with no visible benefit.

**Trail effect** — ghosted duplicates behind a moving element:

```tsx
import {Trail} from '@remotion/motion-blur';

<Trail layers={4} lagInFrames={0.5} trailOpacity={0.6}>
  <MovingElement />
</Trail>
```

- `layers`: number of trail copies.
- `lagInFrames`: time offset per layer.
- `trailOpacity`: opacity of the furthest trail.

### Text effects

Five text animation patterns.

**1. Character stagger:**

```tsx
const text = 'TCGMode';
{text.split('').map((char, i) => {
  const delay = i * 3;
  const enter = spring({frame: Math.max(0, frame - delay), fps, config: {damping: 12}});
  return (
    <span key={i} style={{
      display: 'inline-block',
      opacity: enter,
      transform: `translateY(${(1 - enter) * 20}px)`,
    }}>
      {char}
    </span>
  );
})}
```

**2. Word-by-word reveal:**

```tsx
const words = 'Your source for TCG news'.split(' ');
{words.map((word, i) => {
  const start = i * 8;
  const visible = frame >= start;
  const enter = spring({frame: Math.max(0, frame - start), fps, config: {damping: 14}});
  return (
    <span key={i} style={{
      display: 'inline-block',
      marginRight: 12,
      opacity: visible ? enter : 0,
      transform: `scale(${visible ? 0.8 + enter * 0.2 : 0})`,
    }}>
      {word}
    </span>
  );
})}
```

**3. Typewriter with blinking cursor:**

```tsx
const text = 'npm install remotion';
const chars = Math.floor(interpolate(frame, [0, 60], [0, text.length], {
  extrapolateLeft: 'clamp',
  extrapolateRight: 'clamp',
}));
const cursorVisible = Math.floor(frame / 15) % 2 === 0;

<span style={{fontFamily: 'monospace'}}>
  {text.slice(0, chars)}
  <span style={{opacity: cursorVisible ? 1 : 0}}>▌</span>
</span>
```

**4. Glitch effect:**

```tsx
import {random} from 'remotion';

// Intentionally non-deterministic across frames — new glitch each frame is the point
const glitchOffset = (random(frame * 7 + 1) - 0.5) * 10;
const glitchSkew = (random(frame * 13 + 2) - 0.5) * 5;
const showGlitch = random(frame * 3 + 3) > 0.85; // glitch on ~15% of frames

<div style={{
  transform: showGlitch
    ? `translate(${glitchOffset}px, ${glitchOffset * 0.5}px) skewX(${glitchSkew}deg)`
    : 'none',
  color: showGlitch ? `hsl(${random(frame * 5) * 360}, 100%, 60%)` : 'white',
}}>
  {text}
</div>
```

Note: this intentionally uses `random(frame * N)` to produce a different value each frame — an exception to the "same seed = same value" rule because glitch should look chaotic.

**5. Animated gradient text:**

```tsx
const shift = interpolate(frame, [0, durationInFrames], [0, 200]);

<span style={{
  fontSize: 80,
  fontWeight: 900,
  background: `linear-gradient(90deg, #FFCB05, #F26B3A, #8B5CF6, #FFCB05)`,
  backgroundSize: '200% 100%',
  backgroundPosition: `${shift}% 0`,
  backgroundClip: 'text',
  WebkitBackgroundClip: 'text',
  WebkitTextFillColor: 'transparent',
}}>
  TCGMode
</span>
```

### Morph transition (motion-match cut)

Seamlessly transition between scenes by interpolating an element's position/size across the cut. Use within a `TransitionSeries` overlap:

```tsx
const MorphElement: React.FC<{
  fromRect: {x: number; y: number; w: number; h: number};
  toRect: {x: number; y: number; w: number; h: number};
  progress: number; // 0 = scene A position, 1 = scene B position
  children: React.ReactNode;
}> = ({fromRect, toRect, progress, children}) => {
  const x = interpolate(progress, [0, 1], [fromRect.x, toRect.x]);
  const y = interpolate(progress, [0, 1], [fromRect.y, toRect.y]);
  const w = interpolate(progress, [0, 1], [fromRect.w, toRect.w]);
  const h = interpolate(progress, [0, 1], [fromRect.h, toRect.h]);

  return (
    <div style={{
      position: 'absolute',
      left: x,
      top: y,
      width: w,
      height: h,
      overflow: 'hidden',
    }}>
      {children}
    </div>
  );
};
```

The `progress` value comes from `spring()` or `interpolate()` mapped to the overlapping frames of a `TransitionSeries.Transition`. The trick: render the same visual element in both the exiting and entering sequence, and only during the transition overlap, render the `MorphElement` that bridges them.

