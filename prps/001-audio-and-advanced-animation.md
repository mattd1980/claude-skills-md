# PRP-001: Audio Production & Advanced Animation for remotion-video skill

**Status:** Draft
**Created:** 2026-04-16
**Author:** mdrimonakos + Claude
**Skill:** `skills/remotion-video/`

---

## 1. Problem statement

The `remotion-video` skill produces structurally sound videos — compositions, sequences, transitions, and basic spring/interpolate animations all work on the first pass. But the output *feels* like a slide deck, not a video. Two things are missing:

1. **Audio is an afterthought.** The skill has a few one-liners about `<Audio>` and volume ducking. There's no guidance on SFX timing, music layering, volume automation curves, TTS pipelines, or audio-reactive visuals beyond a basic `visualizeAudio` snippet. Claude generates silent videos or slaps on a single background track with flat volume.

2. **Animations are safe and repetitive.** Every video gets the same spring-in + fade-out treatment. There's no vocabulary for particles, 3D perspective, path drawing, noise-driven organic motion, motion blur, text effects, or morph transitions. Claude reaches for `spring()` and `interpolate()` because that's all the skill teaches.

The result: videos that are *correct* but not *compelling*. The skill needs a production layer.

---

## 2. Goal

After this enhancement, Claude should be able to:

- **Score a video** with layered audio: background music, transition SFX, VO or TTS, with proper volume automation (duck, fade, swell).
- **Choose the right animation technique** for the job: springs for UI, noise for organic textures, path animation for line-drawing, 3D transforms for card flips, motion blur for speed, particles for energy.
- **Generate a TTS pipeline** end-to-end: script → audio file → whisper.cpp transcription → frame-synced captions.
- **React to audio** with visuals: EQ bars, waveforms, beat-synced scale pulses.

All without the user having to explain these concepts — the skill teaches Claude, Claude directs the video.

---

## 3. Deliverables

### 3.1 New file: `AUDIO.md`

The definitive guide to audio in Remotion, structured for Claude consumption.

**Sections:**

#### 3.1.1 `<Audio>` component — full prop reference

Document every prop Claude needs to use correctly:

| Prop | Type | Notes |
|---|---|---|
| `src` | string | URL or `staticFile()` path |
| `volume` | number \| (frame: number) => number | Per-frame callback is the power feature |
| `loop` | boolean | |
| `loopVolumeCurveBehavior` | "repeat" \| "extend" | How the volume callback maps across loops |
| `playbackRate` | number (0.0625–16) | Pitch shifts accordingly |
| `muted` | boolean | |
| `toneFrequency` | number (0.01–2) | **Render-only**, ignored in preview |
| `trimBefore` / `trimAfter` | number (frames) | In source-audio frames at source sample rate |
| `acceptableTimeShiftInSeconds` | number (default 0.45) | Sync drift threshold |
| `audioStreamIndex` | number | **Render-only** — select stream from multi-stream files |
| `name` | string | Label shown in Studio timeline |
| `showInTimeline` | boolean | |

**Gotcha to document:** `toneFrequency` and `audioStreamIndex` are render-only. Don't rely on them in Studio preview.

#### 3.1.2 Volume automation patterns

Six concrete, copy-pasteable patterns with the math explained:

1. **Linear fade in** — `volume={(f) => interpolate(f, [0, 30], [0, 0.8], {clamp})}`
2. **Linear fade out** — last 30 frames to 0
3. **Music duck under VO** — smooth ramp down at VO start, ramp back up at VO end. Use `interpolate` with 4-point range: `[voStart - 15, voStart, voEnd, voEnd + 15]` → `[0.6, 0.15, 0.15, 0.6]`
4. **Swell at transition** — brief volume increase timed to a scene change
5. **Rhythmic pulse** — sine-wave modulation: `volume={(f) => 0.5 + 0.1 * Math.sin(f / fps * Math.PI * bpm / 60)}`
6. **Complete silence for a beat** — useful for dramatic pause before a reveal

Each pattern must include: the volume callback code, when to use it, and how to adjust the timing parameters.

#### 3.1.3 SFX timing

How to place sound effects with frame accuracy:

```tsx
<Sequence from={transitionStartFrame} durationInFrames={sfxDuration}>
  <Audio src={staticFile('sfx/whoosh.mp3')} volume={0.4} />
</Sequence>
```

**SFX-to-transition mapping table:**

| Transition type | Recommended SFX | Timing offset |
|---|---|---|
| `fade()` | Soft ambient swell | Start 5 frames before transition |
| `slide()` | Whoosh / swipe | Start at transition frame |
| `wipe()` | Swoosh (directional) | Start at transition frame |
| Spring entrance | Pop / click | At spring start frame |
| Text reveal | Soft tick per character | Per-character sequence |
| Scale pulse | Thump / bass hit | At peak frame |

**Asset conventions:** `public/sfx/` for effects, `public/music/` for tracks. Name by function: `whoosh.mp3`, `pop.mp3`, `click.mp3`, `ambient-loop.mp3`.

#### 3.1.4 Audio layering

Remotion layers all `<Audio>` components simultaneously. There is **no master gain bus**. Document the pattern for managing multiple tracks:

```tsx
// Layer 1: Background music (constant, ducked under VO)
<Audio src={staticFile('music/bg.mp3')} volume={musicVolume} loop />

// Layer 2: VO (placed in time)
<Sequence from={voStartFrame} durationInFrames={voDuration}>
  <Audio src={staticFile('vo/narration.mp3')} volume={0.9} />
</Sequence>

// Layer 3: SFX (per-transition)
<Sequence from={120} durationInFrames={15}>
  <Audio src={staticFile('sfx/whoosh.mp3')} volume={0.35} />
</Sequence>
```

**Important:** Warn Claude that layering too many tracks without volume management creates muddy audio. Rule of thumb: background music at 0.3–0.5, VO at 0.8–1.0, SFX at 0.3–0.5.

#### 3.1.5 TTS pipeline

End-to-end pattern using `@remotion/install-whisper-cpp`:

**Step 1: Generate audio** — external TTS API (ElevenLabs, Google TTS, OpenAI TTS) or a pre-recorded file. Save to `public/vo/`.

**Step 2: Transcribe for word timing** — in a pre-render script (`generate-captions.mjs`):

```ts
import {installWhisperCpp} from '@remotion/install-whisper-cpp';
import {downloadWhisperModel} from '@remotion/install-whisper-cpp';
import {transcribe} from '@remotion/install-whisper-cpp';
import {toCaptions} from '@remotion/install-whisper-cpp';

const whisperPath = await installWhisperCpp({to: '.whisper', version: '1.5.5'});
await downloadWhisperModel({model: 'medium.en', folder: '.whisper'});
const raw = await transcribe({
  model: '.whisper/ggml-medium.en.bin',
  whisperPath,
  inputPath: 'public/vo/narration.mp3',
  tokenLevelTimestamps: true,
});
const captions = toCaptions({whisperCppOutput: raw});
// Write to public/captions.json
```

**Step 3: Sync in composition** — read `captions.json` via `staticFile` + `delayRender`, map timestamps to frames, render synchronized text.

**Validation criteria for TTS section:**
- Duration mismatch between audio and expected scene length should warn (>15% drift)
- Leading silence >200ms should be flagged
- Speaking rate between 2–4.5 words/second is normal; outside that range, flag

#### 3.1.6 Audio-reactive visuals

Expand the existing `visualizeAudio` pattern into a proper toolkit:

**API reference:**
```ts
visualizeAudio({
  audioData: AudioData,    // from useAudioData()
  frame: number,
  fps: number,
  numberOfSamples: number, // MUST be power of 2 (16, 32, 64, 128)
  smoothing?: number,      // 0–1, averages across adjacent frames
  optimizeFor?: 'accuracy' | 'speed',  // v4.0.83+
}): number[]  // amplitudes 0–1, left=bass, right=highs
```

**Three patterns to include:**

1. **EQ bar visualizer** — map each sample to a bar height
2. **Waveform ring** — polar coordinates, radius modulated by amplitude
3. **Beat-synced scale** — detect bass spike (samples[0] > threshold), trigger spring

Each with a complete, copy-pasteable component.

---

### 3.2 Expanded `PATTERNS.md` — advanced animation section

Add a new `## Advanced animations` section after the existing patterns. Each entry: technique name, when to use, complete snippet, gotchas.

#### 3.2.1 Particle system

Deterministic particles using `random(seed)`:

```tsx
const PARTICLE_COUNT = 80;
const particles = new Array(PARTICLE_COUNT).fill(0).map((_, i) => ({
  x: random(`x-${i}`) * width,
  y: random(`y-${i}`) * height,
  size: 2 + random(`s-${i}`) * 4,
  speed: 0.5 + random(`sp-${i}`) * 1.5,
  opacity: 0.2 + random(`o-${i}`) * 0.4,
}));
```

Animate position from `frame * speed`. Wrap with modulo for looping. Document performance note: >200 DOM particles gets slow — for heavy particle work, recommend `<Canvas>` (2D canvas) or `@remotion/three`.

#### 3.2.2 3D perspective transforms

CSS-only 3D — no Three.js needed:

- Card flip: `rotateY` from 0 to 180deg with `backfaceVisibility: 'hidden'` on front/back
- Tilt on entrance: `perspective(1000px) rotateX(15deg)` eased to `rotateX(0)`
- Depth parallax: multiple layers at different `translateZ` values inside a `perspective` container

**Gotcha:** `transform` order matters. Use `makeTransform()` from `@remotion/animation-utils` for composability and type safety.

**Gotcha:** SVG elements default to top-left transform origin. Always set `transformBox: 'fill-box'` and `transformOrigin: 'center center'` on SVG.

#### 3.2.3 SVG path drawing (line-draw effect)

Using `@remotion/paths`:

```tsx
import {getLength, getPointAtLength} from '@remotion/paths';

const path = 'M 10 80 C 40 10, 65 10, 95 80';
const length = getLength(path);
const drawn = interpolate(frame, [0, 60], [length, 0], {clamp});

<svg><path d={path} strokeDasharray={length} strokeDashoffset={drawn} /></svg>
```

Also document: animate-along-path (move an element along an SVG path using `getPointAtLength`).

#### 3.2.4 Path morphing

```tsx
import {interpolatePath} from '@remotion/paths';

const progress = spring({frame, fps, config: {damping: 14}});
const d = interpolatePath(progress, starPath, circlePath);
```

Both paths should have the same number of commands for clean morphing. Use `@remotion/shapes` to generate well-matched paths (e.g., `makeStarPath()` → `makeCirclePath()`).

#### 3.2.5 Noise-driven organic motion

Using `@remotion/noise`:

```tsx
import {noise2D, noise3D} from '@remotion/noise';

// Gentle floating: use frame/fps as time axis
const dx = noise2D('x', frame / fps * 0.5, 0) * 20;
const dy = noise2D('y', 0, frame / fps * 0.5) * 15;
```

Use cases: floating background elements, breathing/pulsing effects, organic camera shake, procedural textures.

**3D noise** for color shifts: `noise3D('color', x, y, frame / fps)` mapped to hue offset.

#### 3.2.6 Motion blur

Using `@remotion/motion-blur`:

```tsx
import {CameraMotionBlur} from '@remotion/motion-blur';

<CameraMotionBlur shutterAngle={180} samples={10}>
  <AbsoluteFill>{/* fast-moving content */}</AbsoluteFill>
</CameraMotionBlur>
```

- `shutterAngle`: 0–360 (180 = cinema standard, 360 = max blur)
- `samples`: more = smoother but slower and color-destructive. Keep 5–10.
- Children **must** use `<AbsoluteFill>` (absolute positioning required).
- Use for: fast pans, zoom transitions, speed ramps. Skip for static/slow scenes (expensive for no visible benefit).

Also document `<Trail>`:
```tsx
<Trail layers={4} lagInFrames={0.5} trailOpacity={0.6}>
  <MovingElement />
</Trail>
```

#### 3.2.7 Text effects

Five text animation patterns:

1. **Character stagger** — each character springs in with `delay = i * 3 frames`
2. **Word-by-word reveal** — words appear sequentially, triggered by frame ranges
3. **Typewriter with cursor** — character count from `interpolate`, blinking cursor via `Math.floor(frame / 15) % 2`
4. **Glitch effect** — randomly offset slices using `random(frame + seed)` (produces a new glitch pattern each frame, which is intentional for this effect — exception to the determinism rule)
5. **Gradient text animation** — animate `backgroundPosition` of a gradient used as `backgroundClip: 'text'`

#### 3.2.8 Morph transition (motion-match cut)

Interpolate position, size, and style of an element between two scenes for a seamless cross-scene transition. Pattern:

```tsx
const rect1 = {x: 100, y: 200, w: 300, h: 200}; // position in scene A
const rect2 = {x: 500, y: 100, w: 600, h: 400}; // position in scene B
const progress = spring({frame, fps, config: {damping: 14}});
const x = interpolate(progress, [0, 1], [rect1.x, rect2.x]);
// ... same for y, w, h
```

Use with `<TransitionSeries>` where the overlapping frames render the morphing element.

---

### 3.3 Updates to existing files

#### 3.3.1 `SKILL.md`

Add to the quick decision tree:
- **User wants background music** → see `AUDIO.md`
- **User wants SFX on transitions** → see `AUDIO.md#sfx-timing`
- **User wants TTS/voiceover** → see `AUDIO.md#tts-pipeline`
- **User wants fancy animation** → see `PATTERNS.md#advanced-animations`

Update supporting references list to include `AUDIO.md`.

#### 3.3.2 `PACKAGES.md`

Add entries for:
- `@remotion/motion-blur` — CameraMotionBlur and Trail components
- `@remotion/animation-utils` — `makeTransform()` for composable CSS transforms

Verify `@remotion/noise`, `@remotion/paths`, `@remotion/shapes` already have entries (they do).

#### 3.3.3 `/demo-feature-video` command

Update Phase 4 (Build) to:
- Default to adding a background music track if the user provides one
- Add SFX on `TransitionSeries` transitions by default (whoosh on slide, soft swell on fade)
- Use character-stagger for title card text instead of plain spring
- Use noise-driven subtle motion on background elements

---

## 4. What NOT to build

- **No asset generation** — don't build an AI music/SFX generation pipeline. That's a separate skill. This PRP is about teaching Claude to *use* audio/animation assets, not create them.
- **No `@remotion/three` deep-dive** — 3D via React Three Fiber is its own skill. CSS 3D transforms are sufficient for the demo-video use case. Mention Three.js as an option, link to the template, but don't write a Three.js guide.
- **No custom Web Audio API processing** — `useWebAudioApi` only works in headless render, not preview. Too fragile to teach as a default. Stick to `<Audio>` + `visualizeAudio`.

---

## 5. Implementation order

1. **`AUDIO.md`** — write the full file (sections 3.1.1 through 3.1.6). This is the highest-impact gap.
2. **`PATTERNS.md` advanced section** — add sections 3.2.1 through 3.2.8 as a new `## Advanced animations` block after the existing patterns.
3. **`SKILL.md` + `PACKAGES.md`** updates — wire in the new references.
4. **`/demo-feature-video`** — update Phase 4 defaults to use the new capabilities.
5. **Audit pass** — re-read all files for consistency, cross-references, and overlap.

---

## 6. Validation criteria

After implementation, the skill should pass these tests:

- [ ] Claude can generate a video with layered audio (music + SFX + VO) without being told how volume ducking works
- [ ] Claude reaches for the right animation technique (noise for organic, spring for UI, path for line-drawing) based on context
- [ ] The TTS pipeline section is complete enough to produce synced captions from a script on the first pass
- [ ] Audio-reactive patterns produce working visualizers without missing imports or wrong `visualizeAudio` usage
- [ ] Every code snippet in `AUDIO.md` and the new `PATTERNS.md` sections compiles and renders without error
- [ ] The `/demo-feature-video` command's default output includes at least: background music (if provided), SFX on transitions, and one advanced animation technique
- [ ] No existing patterns or rules are broken by the additions

---

## 7. Open questions (resolved)

1. ~~**SFX files**~~ → **Resolved:** recommend Kenney (CC0), Freesound, Mixkit, Pixabay, and `@remotion/sfx` as the zero-friction first choice. Documented in `AUDIO.md#recommended-free-sfx-sources`.
2. ~~**ElevenLabs / OpenAI TTS**~~ → **Resolved:** include both. OpenAI TTS (`openai` npm) and ElevenLabs (`elevenlabs` npm) with minimal Node.js code. Documented in `AUDIO.md#tts-pipeline`.
3. ~~**`@remotion/sfx`**~~ → **Resolved:** confirmed real. `@remotion/sfx` v4.0.448, official Remotion monorepo package. Documented in `AUDIO.md` and `PACKAGES.md`.

---

## 8. References

- Remotion Audio docs: https://www.remotion.dev/docs/audio
- Audio visualization: https://www.remotion.dev/docs/visualize-audio
- Whisper.cpp: https://www.remotion.dev/docs/install-whisper-cpp
- Motion blur: https://www.remotion.dev/docs/motion-blur
- Paths: https://www.remotion.dev/docs/paths
- Noise: https://www.remotion.dev/docs/noise
- Shapes: https://www.remotion.dev/docs/shapes
- Animation utils: https://www.remotion.dev/docs/animation-utils
- Audio transitions: https://www.remotion.dev/docs/transitions/audio-transitions
- Remotion showcase: https://www.remotion.dev/showcase
- Remotion official skills repo: https://github.com/remotion-dev/skills
