---
name: create-nes-challenge
description: Standardized recipe for adding a new RetroChallenges/FlawlessNES challenge. Locks in countdown behavior, HUD layout, detection patterns, anti-cheat thresholds, manifest housekeeping, and savestate conventions so every challenge feels the same to the player. Use when the user asks to "add a challenge", "create a challenge", or describes a new win/fail goal in any NES game.
---

# Create NES challenge

Every challenge in this project lives in three places — the `.lua` script, the savestate, and the `challenges.json` manifest entry. This skill exists because deviating from the recipe (skipping countdown, custom HUD layout, missing anti-cheat thresholds, no savestate fallback) breaks the player experience in ways that compound. Follow it.

## Repos and paths

| Thing | Path |
|---|---|
| Challenge scripts + savestates | `T:/repos/retrochallenges-assets/nes/<game>/<challenge-folder>/` |
| Manifest | `T:/repos/retrochallenges-assets/challenges.json` |
| Framework | `T:/repos/retrochallenges-assets/utils/RcChallenge.lua` + `RcHud.lua` |
| Leaderboard | `T:/repos/retrochallenges-leaderboard/` |
| Desktop app | `T:/repos/RetroChallenges/` |

## Folder layout — required

```
nes/<game>/<challenge-folder>/
  <challenge-folder>.lua
  savestates/<challenge-folder>.State
```

- Folder names: `kebab-case`, descriptive (`eat-blinky`, `pacifist-stage-1`, `boss-metalman`).
- The `.lua` filename, the folder name, and the `.State` filename must all match.
- Savestate file extension is `.State` (capital S — BizHawk default).

## The .lua spec — mandatory contract

Every `challenge.run{}` call MUST include these fields. **No exceptions.**

```lua
local hud       = require("RcHud")
local challenge = require("RcChallenge")
local read_u8   = memory.read_u8 or memory.readbyte

-- RAM addresses with documented source — paste the URL.
local ADDR_FOO = 0x????

-- Per-attempt baselines at file scope, RESET in setup().
local prev_foo = 0

challenge.run{
    savestate           = "savestates/<folder>.State",
    expected_rom_hashes = {},  -- empty on first ship; populate after BizHawk console logs the SHA1

    setup  = function(state) emu.frameadvance(); prev_foo = read_u8(ADDR_FOO) end,
    win    = function() return ... end,
    fail   = function() ... end,
    hud    = function(state) ... end,
    result = function(state) return { score = ..., completionTime = state.elapsed } end,
}
```

### What you MUST NOT do

| Don't | Why |
|---|---|
| `countdown = false` | Players expect 3-2-1-GO across every challenge. The framework's universal freeze (savestate-reload, slot 9) handles games without a per-game pause byte — there's no longer any reason to skip it. |
| Custom `freeze_game` / `release_game` unless you have a documented per-game pause byte | The universal freeze covers it. Per-game callbacks are only worth adding when you've found the byte in the disassembly. |
| Submit without `expected_rom_hashes = {}` | If you don't know the SHA1 yet, leave it empty (fail-open). Don't make up a value. |
| Skip the `Source:` URL above each address block | RAM-map decisions are the most error-prone part. The link is what saves you when the addresses turn out wrong on a different ROM revision. |
| Use `score` HUD without showing the threshold | Player needs to see how close they are to the goal. |

## HUD layout — fixed grid

Four rows starting at y=6 with 18px vertical spacing. **Always.**

```
y=6:   SCORE       <current> / <target if applicable>
y=24:  <CONTEXT>   game-specific stat (LIVES, DOTS, CHAIN N/4, BLINKY pos, etc.)
y=42:  <CONTEXT>   optional second context line
y=60:  TIME        hud.drawTime(48, 58, state.elapsed)
```

If the win predicate is non-obvious (anything beyond "score >= N" or "level advances"), include a debug line that shows what the predicate is reading. Example for Eat Blinky:

```lua
gui.text(10, 24, "DELTA")
gui.text(48, 24, tostring(last_score_delta))   -- live feedback for ghost-eat detection
```

The HUD is your debugging surface — when the user reports "challenge didn't fire," they read it back to you and you don't need BizHawk yourself.

## Detection patterns

Pick the one that matches the goal. Each one is battle-tested.

### Score >= target
```lua
local TARGET = 2000
win = function() return read_score() >= TARGET end
```

### Lives decrement (universal "die ends run")
```lua
local prev_lives = 0
setup = function() prev_lives = read_u8(LIVES) end
fail = function()
    local now = read_u8(LIVES)
    if now < prev_lives then return true end
    prev_lives = now
    return false
end
```

### Level / stage advances (cleared the level)
```lua
local initial_level = 0
setup = function() initial_level = read_u8(LEVEL) end
win = function() return read_u8(LEVEL) > initial_level end
```
Robust against zero- vs one-indexed level bytes and any in-game animation between "last enemy killed" and "next stage drawn."

### Specific entity defeated (e.g., Eat Blinky in Pac-Man)
Score-delta + position-teleport combo. When ANY ghost is eaten, the score jumps by exactly 200/400/800/1600 in one frame; only the eaten ghost's coordinates teleport (>16px in one frame vs. the normal 1px). Combine both signals.

```lua
local GHOST_EAT_DELTAS = { [200]=true, [400]=true, [800]=true, [1600]=true }
local TELEPORT_THRESHOLD = 16

win = function()
    local cur_score = read_score()
    local cur_x, cur_y = read_u8(BLINKY_X), read_u8(BLINKY_Y)
    local delta = cur_score - prev_score
    local dx = math.abs(cur_x - prev_x)
    local dy = math.abs(cur_y - prev_y)
    prev_score, prev_x, prev_y = cur_score, cur_x, cur_y
    return GHOST_EAT_DELTAS[delta] and (dx > TELEPORT_THRESHOLD or dy > TELEPORT_THRESHOLD)
end
```

### Combo / chain detection (e.g., 4-ghost combo)
Track a counter that increments on each detection event and resets if too long passes between events.

```lua
local CHAIN_TIMEOUT_FRAMES = 480  -- ~8s, frightened-timer upper bound
local chain_count, last_eat_frame = 0, -10000

win = function(state)
    local delta = read_score() - prev_score
    prev_score = prev_score + delta
    if GHOST_EAT_DELTAS[delta] then
        if state.elapsed - last_eat_frame > CHAIN_TIMEOUT_FRAMES then
            chain_count = 1
        else
            chain_count = chain_count + 1
        end
        last_eat_frame = state.elapsed
    end
    return chain_count >= 4
end
```

### Negative-space constraint (e.g., Pacifist — clear stage without eating ghosts)
Win predicate is the positive goal; add the constraint to `fail`.

```lua
fail = function()
    -- normal death check
    local now = read_u8(LIVES)
    if now < prev_lives then return true end
    prev_lives = now
    -- pacifist constraint
    local delta = read_score() - prev_score
    prev_score = prev_score + delta
    if GHOST_EAT_DELTAS[delta] then return true end
    return false
end
```

## RAM-address research

Before writing a single line of Lua, look up the RAM map:

1. Try **Data Crystal** first: `https://datacrystal.tcrf.net/wiki/<Game>_(NES)/RAM_map` (or the FDS / Famicom variant — close-enough layouts often share addresses).
2. Paste the source URL above the address block as a comment.
3. Note the format explicitly: BCD-packed two-digits-per-byte (Castlevania, Donkey Kong) vs. one-digit-per-byte (Pac-Man) vs. raw binary.
4. If addresses don't behave as expected when the user tests, add live debug values to the HUD (don't try to guess — the HUD shows truth).

## Manifest entry — required fields

```json
{
  "name": "<Display Name with proper capitalization and punctuation>",
  "description": "<2-3 sentences. KEEP IT SHORT — desktop app truncates at ~120 chars in the picker. Focus on the goal + the catch.>",
  "lua": "nes\\<game>\\<folder>\\<folder>.lua",
  "difficulty": "Easy" | "Medium" | "Hard" | "Very Hard",
  "category": "boss" | "speedrun" | "survival" | "score",
  "estimatedTime": "<range, e.g. '1-3 minutes'>",
  "minPlausibleFrames": <see heuristic below>,
  "flagBelowFrames":    <see heuristic below>,
  "grades": {
    "by": "time",
    "thresholds": [
      { "grade": "SSS", "maxFrames": <SSS> },
      { "grade": "SS",  "maxFrames": <SSS * 1.6> },
      { "grade": "S",   "maxFrames": <SSS * 2.5> },
      { "grade": "A",   "maxFrames": <SSS * 4> },
      { "grade": "B",   "maxFrames": 999999 }
    ]
  }
}
```

After adding the entry, bump the `metadata` block:
- `version`: minor +1
- `totalChallenges`: +1
- `totalGames`: +1 ONLY if this is the first challenge for a brand-new game
- `lastUpdated`: today's date in ISO format

## Anti-cheat thresholds

| Field | Heuristic | Effect |
|---|---|---|
| `minPlausibleFrames` | ~33% of SSS | Submit endpoint rejects 400 — physically impossible time |
| `flagBelowFrames` | ~80% of SSS | Submit endpoint queues to `/admin/pending` for review |

Only set `flagBelowFrames` close to SSS if you expect frequent SSS attempts; otherwise keep the gap so casual SSS runs don't all funnel into the queue.

## Savestate

You generally cannot create the `.State` file yourself (no BizHawk + ROM access). When the user has provided one, match its filename to the folder. When they haven't, write a `savestates/README.md` with explicit capture instructions:

1. Open BizHawk 2.11.
2. Load the ROM.
3. Navigate to the desired starting moment (READY screen, level start, boss room, etc. — pick a state that minimizes pre-play setup).
4. **File → Save State → Save Named State…** and save as `<folder>.State` directly into the savestates dir.

The framework's universal freeze (slot 9) takes care of the countdown overlay, so the savestate doesn't need to be at a "naturally paused" frame any more — pick whatever moment maximizes player agency on frame 1 of play.

## ROM hash

Leave `expected_rom_hashes = {}` until the user runs the challenge once. The framework logs `[RC] ROM SHA1: <hash>` to BizHawk's Lua console on every launch — the user pastes that into the array to lock the challenge to their dump.

## Testing — what you CAN do without BizHawk

You can't run the challenge yourself. Compensate with:
- Documented RAM source (Data Crystal URL in a comment)
- Conservative anti-cheat thresholds (more flagged for review > silently rejected legitimate runs)
- HUD shows live values of every byte the predicate reads (when the user reports a bug, they read back the values)
- Empty `expected_rom_hashes` so wrong-ROM doesn't add a confounding variable

## Commit message convention

```
feat(<game>): add <Challenge Name>

Win:  <one line>
Fail: <one line>

RAM addresses derived from <source URL>:
  $XXXX = <name> (<format note>)
  ...

HUD: <what's shown to the player>

Manifest: X.Y.Z → X.Y+1.0; totalChallenges N → N+1.
Anti-cheat: SSS=Nf / flagBelow=Nf / minPlausible=Nf

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
```

The assets repo doesn't gate on PRs — commits go straight to `main`. Push when ready.

## Leaderboard side

If you're adding a brand-new GAME (not just a challenge), confirm `listGames()` and `listChallengeSummaries()` in `src/lib/leaderboard.ts` union with the manifest — they should already, but verify a manifest-only game/challenge appears as an empty tile/row immediately after the manifest cache rolls (~5 min TTL).

## Pre-flight checklist

- [ ] Folder name = .lua name = .State name
- [ ] `expected_rom_hashes = {}` initially
- [ ] No `countdown = false` (let the universal freeze do its job)
- [ ] All baselines initialized in `setup()`, not at file scope
- [ ] HUD has SCORE / context / TIME rows in the standard grid
- [ ] HUD shows live values of any non-trivial detection state
- [ ] RAM source URL pasted as comment
- [ ] Manifest entry has all 9 fields including both anti-cheat thresholds
- [ ] Manifest version + totalChallenges bumped
- [ ] (If new game) Box-art URL set, totalGames bumped
- [ ] Commit message follows the template
