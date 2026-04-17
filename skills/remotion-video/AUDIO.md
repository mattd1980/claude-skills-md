# Remotion audio production

Everything about sound in Remotion: the `<Audio>` component, volume automation, SFX timing, audio layering, TTS pipelines, and audio-reactive visuals.

## `<Audio>` component — full prop reference

All props on `<Audio>` from `'remotion'`:

| Prop | Type | Default | Notes |
|---|---|---|---|
| `src` | string | — | URL or `staticFile()` path. Required. |
| `volume` | number \| `(frame: number) => number` | 1 | Per-frame callback is the power feature — use it for all automation. |
| `loop` | boolean | false | |
| `loopVolumeCurveBehavior` | `'repeat'` \| `'extend'` | `'repeat'` | How the volume callback maps across loops. `'extend'` continues frame count. |
| `playbackRate` | number | 1 | Range 0.0625–16. Pitch shifts proportionally. |
| `muted` | boolean | false | |
| `toneFrequency` | number | — | Range 0.01–2. **Render-only** — ignored in Studio/Player. |
| `trimBefore` | number | — | Trim start (source-audio frames). |
| `trimAfter` | number | — | Trim end (source-audio frames). |
| `acceptableTimeShiftInSeconds` | number | 0.45 | Sync drift threshold before seeking. |
| `audioStreamIndex` | number | — | Select audio stream from multi-stream files. **Render-only.** |
| `name` | string | — | Label shown in Studio timeline. |
| `showInTimeline` | boolean | true | |
| `delayRenderTimeoutInMilliseconds` | number | 30000 | Timeout for audio loading. |
| `delayRenderRetries` | number | 0 | |

**Gotchas:**
- `toneFrequency` and `audioStreamIndex` are **render-only** — they do nothing in preview/Studio/Player. Don't use them for dev feedback.
- The volume callback receives the **composition frame**, not the audio file's internal frame. If the `<Audio>` is inside a `<Sequence>`, the frame resets to 0 at the sequence start.

## `@remotion/sfx` — built-in sound effects

Remotion ships a first-party SFX library. Install:

```bash
npm install @remotion/sfx
```

Check https://www.remotion.dev/docs/sfx for the available sounds and API. Use these for transitions and UI interactions before reaching for external assets.

## Volume automation patterns

Six patterns for the volume callback. All assume the `<Audio>` is inside a `<Sequence>` so `frame` is sequence-local.

### 1. Fade in

```tsx
<Audio
  src={staticFile('music/bg.mp3')}
  volume={(f) =>
    interpolate(f, [0, 30], [0, 0.6], {
      extrapolateLeft: 'clamp',
      extrapolateRight: 'clamp',
    })
  }
/>
```

Ramp from silence to 0.6 over 1 second (30 frames at 30fps). Adjust the `30` to taste.

### 2. Fade out

Use when you know the sequence duration:

```tsx
<Audio
  src={staticFile('music/bg.mp3')}
  volume={(f) =>
    interpolate(f, [durationInFrames - 45, durationInFrames], [0.6, 0], {
      extrapolateLeft: 'clamp',
      extrapolateRight: 'clamp',
    })
  }
/>
```

### 3. Fade in + fade out

```tsx
<Audio
  src={staticFile('music/bg.mp3')}
  volume={(f) => {
    const fadeIn = interpolate(f, [0, 30], [0, 0.6], {
      extrapolateLeft: 'clamp',
      extrapolateRight: 'clamp',
    });
    const fadeOut = interpolate(f, [durationInFrames - 45, durationInFrames], [0.6, 0], {
      extrapolateLeft: 'clamp',
      extrapolateRight: 'clamp',
    });
    return Math.min(fadeIn, fadeOut);
  }}
/>
```

### 4. Duck under voiceover

Smoothly lower music when VO starts, raise when it ends. The 15-frame ramps prevent jarring cuts.

```tsx
// voStart/voEnd are frame numbers in the parent composition
const musicVolume = (f: number) =>
  interpolate(
    f,
    [voStart - 15, voStart, voEnd, voEnd + 15],
    [0.6, 0.15, 0.15, 0.6],
    {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'},
  );

<Audio src={staticFile('music/bg.mp3')} volume={musicVolume} loop />
```

**Why 0.15, not 0?** Silence feels like the music broke. A quiet bed under narration sounds intentional.

### 5. Swell at transition

Brief volume increase to punctuate a scene change:

```tsx
const swellVolume = (f: number) =>
  interpolate(
    f,
    [transitionFrame - 10, transitionFrame, transitionFrame + 10],
    [0.5, 0.8, 0.5],
    {extrapolateLeft: 'clamp', extrapolateRight: 'clamp'},
  );
```

### 6. Dramatic silence

Mute everything for a beat, then bring it back — powerful before a reveal.

```tsx
const silenceVolume = (f: number) => {
  if (f >= silenceStart && f < silenceEnd) return 0;
  const rampOut = interpolate(f, [silenceStart - 8, silenceStart], [0.6, 0], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  const rampIn = interpolate(f, [silenceEnd, silenceEnd + 8], [0, 0.6], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  if (f < silenceStart) return rampOut;
  return rampIn;
};
```

## SFX timing

Place sound effects with frame accuracy by wrapping `<Audio>` in a `<Sequence>`:

```tsx
<Sequence from={transitionStartFrame} durationInFrames={20}>
  <Audio src={staticFile('sfx/whoosh.mp3')} volume={0.4} />
</Sequence>
```

### SFX-to-transition mapping

| Transition type | Recommended SFX | Timing offset |
|---|---|---|
| `fade()` | Soft ambient swell | Start **5 frames before** transition |
| `slide()` | Whoosh / swipe | Start **at** transition frame |
| `wipe()` | Directional swoosh | Start **at** transition frame |
| Spring entrance (`spring()`) | Pop / click | At the spring's start frame |
| Text reveal (character stagger) | Soft tick per character | One per character entrance |
| Scale pulse | Thump / bass hit | At the peak frame |
| Scene cut (hard) | Impact / hit | At the cut frame |

### Asset conventions

```
public/
  sfx/       whoosh.mp3, pop.mp3, click.mp3, impact.mp3, tick.mp3
  music/     bg-loop.mp3, accent-sting.mp3
  vo/        narration.mp3
```

Name by function, not by source. Keep SFX short (0.3–2s). Keep music as loops where possible.

### Recommended free SFX sources

| Source | URL | License | Best for |
|---|---|---|---|
| **Kenney** | https://kenney.nl/assets?q=audio | CC0 (public domain) | UI sounds, clicks, pops — clean and consistent |
| **Freesound** | https://freesound.org | Varies (CC0, CC-BY) | Wide variety — check per-sound license |
| **Mixkit** | https://mixkit.co/free-sound-effects/ | Free license | Whooshes, transitions, impacts |
| **Pixabay** | https://pixabay.com/sound-effects/ | Pixabay license (free commercial) | Background music + SFX |
| **@remotion/sfx** | (npm package) | Remotion license | Built-in, zero-friction — check this first |

Always verify the license fits the user's project before recommending a specific source.

## Audio layering

Remotion layers all `<Audio>` components simultaneously. There is **no master gain bus or mixer**. Every track plays independently.

### Standard three-layer stack

```tsx
// Layer 1: Background music — constant, low, ducked under VO
<Audio src={staticFile('music/bg-loop.mp3')} volume={musicVolume} loop />

// Layer 2: Voiceover — placed in time
<Sequence from={voStartFrame} durationInFrames={voDuration}>
  <Audio src={staticFile('vo/narration.mp3')} volume={0.9} />
</Sequence>

// Layer 3: SFX — per-transition, per-event
<Sequence from={120} durationInFrames={20}>
  <Audio src={staticFile('sfx/whoosh.mp3')} volume={0.35} />
</Sequence>
<Sequence from={200} durationInFrames={15}>
  <Audio src={staticFile('sfx/pop.mp3')} volume={0.4} />
</Sequence>
```

### Volume hierarchy

| Layer | Typical volume | Why |
|---|---|---|
| Voiceover | 0.8–1.0 | Voice is king — always audible. |
| SFX | 0.3–0.5 | Punctuation, not distraction. |
| Background music | 0.3–0.5 normal, 0.1–0.2 ducked | Bed, not foreground. |

**Rule:** if you sum the volumes and they exceed ~1.3, the output will clip. Either lower individual tracks or accept minor distortion. Remotion has no limiter.

## TTS pipeline

Generate voiceover from a text script, transcribe for word-timed captions, and sync in the composition.

### Step 1: Generate audio

**Option A — OpenAI TTS** (`openai` npm package):

```ts
// scripts/generate-vo.ts
import OpenAI from 'openai';
import {writeFile} from 'fs/promises';

const openai = new OpenAI(); // uses OPENAI_API_KEY env var
const response = await openai.audio.speech.create({
  model: 'tts-1-hd',         // 'tts-1' for faster/cheaper
  voice: 'nova',             // alloy, echo, fable, onyx, nova, shimmer
  input: 'Your script text here.',
  response_format: 'mp3',
});
await writeFile('public/vo/narration.mp3', Buffer.from(await response.arrayBuffer()));
```

- Max 4096 characters per request. For longer scripts, split into paragraphs and concatenate with ffmpeg.
- 6 built-in voices. `nova` and `shimmer` are more expressive; `onyx` is deep/authoritative.

**Option B — ElevenLabs** (`elevenlabs` npm package):

```ts
// scripts/generate-vo.ts
import {ElevenLabsClient} from 'elevenlabs';
import {createWriteStream} from 'fs';

const client = new ElevenLabsClient({apiKey: process.env.ELEVENLABS_API_KEY});
const audio = await client.textToSpeech.convert(
  'JBFqnCBsd6RMkjVDRZzb',   // voice ID — find in their voice library
  {
    text: 'Your script text here.',
    model_id: 'eleven_multilingual_v2',
    output_format: 'mp3_44100_128',
  },
);
const stream = createWriteStream('public/vo/narration.mp3');
for await (const chunk of audio) stream.write(chunk);
stream.end();
```

- Free tier: 10k chars/month. Paid plans: much higher.
- Custom voice cloning available on paid tiers.
- Voice IDs are required (no default) — browse their library or use their API to list available voices.

**Option C — Pre-recorded** — user provides an mp3/wav file. Skip to Step 2.

### Step 2: Transcribe for word timing

Use `@remotion/install-whisper-cpp` to get word-level timestamps:

```ts
// scripts/generate-captions.ts
import {
  installWhisperCpp,
  downloadWhisperModel,
  transcribe,
  toCaptions,
} from '@remotion/install-whisper-cpp';
import {writeFileSync} from 'fs';

const whisperPath = await installWhisperCpp({to: '.whisper', version: '1.5.5'});
await downloadWhisperModel({model: 'medium.en', folder: '.whisper'});

const raw = await transcribe({
  model: '.whisper/ggml-medium.en.bin',
  whisperPath,
  inputPath: 'public/vo/narration.mp3',
  tokenLevelTimestamps: true,
});

const captions = toCaptions({whisperCppOutput: raw});
writeFileSync('public/captions.json', JSON.stringify(captions, null, 2));
```

Output: an array of caption objects with `startMs`, `endMs`, `text`, and per-token timestamps.

### Step 3: Sync in composition

Load captions with `delayRender`, map ms to frames, render as timed text:

```tsx
import {useEffect, useState} from 'react';
import {
  AbsoluteFill, Audio, Sequence, continueRender, delayRender,
  staticFile, useVideoConfig,
} from 'remotion';

type Caption = {text: string; startMs: number; endMs: number};

export const NarratedScene: React.FC = () => {
  const {fps} = useVideoConfig();
  const [handle] = useState(() => delayRender('Loading captions'));
  const [captions, setCaptions] = useState<Caption[]>([]);

  useEffect(() => {
    fetch(staticFile('captions.json'))
      .then((r) => r.json())
      .then((data) => {
        setCaptions(data);
        continueRender(handle);
      });
  }, [handle]);

  return (
    <AbsoluteFill>
      <Audio src={staticFile('vo/narration.mp3')} volume={0.9} />
      {captions.map((c, i) => {
        const from = Math.round((c.startMs / 1000) * fps);
        const dur = Math.max(1, Math.round(((c.endMs - c.startMs) / 1000) * fps));
        return (
          <Sequence key={i} from={from} durationInFrames={dur}>
            <AbsoluteFill style={{justifyContent: 'flex-end', alignItems: 'center', paddingBottom: 80}}>
              <span style={{
                color: 'white', fontSize: 48, fontWeight: 700,
                background: 'rgba(0,0,0,0.6)', padding: '8px 20px', borderRadius: 8,
              }}>
                {c.text}
              </span>
            </AbsoluteFill>
          </Sequence>
        );
      })}
    </AbsoluteFill>
  );
};
```

### TTS quality checks

Flag these before rendering:

| Check | Threshold | Action |
|---|---|---|
| Audio duration vs scene duration | >15% mismatch | Warn — adjust scene durationInFrames or re-generate audio |
| Leading silence | >200ms | Trim with `trimBefore` or re-generate with tighter prompt |
| Speaking rate | <2 or >4.5 words/sec | May sound unnatural — adjust TTS speed or split text |

## Audio-reactive visuals

Drive animation from audio amplitude using `@remotion/media-utils`.

### API reference

```ts
import {useAudioData, visualizeAudio} from '@remotion/media-utils';

const audioData = useAudioData(src); // returns AudioData | null (handles delayRender)
if (!audioData) return null;

const visualization = visualizeAudio({
  audioData,
  frame,
  fps,
  numberOfSamples: 64,  // MUST be a power of 2 (16, 32, 64, 128)
  smoothing: 0.5,        // 0–1, averages with adjacent frames
  optimizeFor: 'speed',  // 'accuracy' | 'speed' (v4.0.83+)
});
// Returns number[] of length numberOfSamples
// Values 0–1, index 0 = lowest frequency (bass), last index = highest (treble)
```

### Pattern 1: EQ bar visualizer

```tsx
const EQBars: React.FC<{src: string}> = ({src}) => {
  const frame = useCurrentFrame();
  const {fps, height} = useVideoConfig();
  const audioData = useAudioData(src);
  if (!audioData) return null;

  const bars = visualizeAudio({audioData, frame, fps, numberOfSamples: 32, smoothing: 0.8});

  return (
    <AbsoluteFill style={{flexDirection: 'row', alignItems: 'flex-end', justifyContent: 'center', gap: 4}}>
      <Audio src={src} />
      {bars.map((amp, i) => (
        <div
          key={i}
          style={{
            width: 12,
            height: amp * height * 0.6,
            borderRadius: 6,
            background: `hsl(${(i / bars.length) * 120 + 200}, 80%, 60%)`,
          }}
        />
      ))}
    </AbsoluteFill>
  );
};
```

### Pattern 2: Beat-synced scale pulse

Detect bass spike and trigger a spring:

```tsx
const BeatPulse: React.FC<{src: string; children: React.ReactNode}> = ({src, children}) => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();
  const audioData = useAudioData(src);
  if (!audioData) return null;

  const viz = visualizeAudio({audioData, frame, fps, numberOfSamples: 16, smoothing: 0.3});
  const bass = viz[0] ?? 0;
  const scale = 1 + bass * 0.3; // 30% max growth on bass hit

  return (
    <AbsoluteFill style={{justifyContent: 'center', alignItems: 'center'}}>
      <Audio src={src} />
      <div style={{transform: `scale(${scale})`}}>{children}</div>
    </AbsoluteFill>
  );
};
```

### Pattern 3: Waveform ring

Amplitude mapped to radius in polar coordinates:

```tsx
const WaveformRing: React.FC<{src: string}> = ({src}) => {
  const frame = useCurrentFrame();
  const {fps, width, height} = useVideoConfig();
  const audioData = useAudioData(src);
  if (!audioData) return null;

  const samples = visualizeAudio({audioData, frame, fps, numberOfSamples: 64, smoothing: 0.6});
  const cx = width / 2;
  const cy = height / 2;
  const baseRadius = 150;

  const points = samples.map((amp, i) => {
    const angle = (i / samples.length) * Math.PI * 2;
    const r = baseRadius + amp * 120;
    return `${cx + Math.cos(angle) * r},${cy + Math.sin(angle) * r}`;
  });

  return (
    <AbsoluteFill>
      <Audio src={src} />
      <svg width={width} height={height}>
        <polygon
          points={points.join(' ')}
          fill="none"
          stroke="rgba(139, 92, 246, 0.8)"
          strokeWidth={2}
        />
      </svg>
    </AbsoluteFill>
  );
};
```
