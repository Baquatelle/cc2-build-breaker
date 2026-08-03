# Brick Breaker — Requirements & Scope

## Overview
A Processing (Java mode) sketch implementing a classic brick breaker
(Breakout-style) game. This implementation extends the original scope with
**power‑ups**, **multiple levels**, **multi‑ball**, **sound effects**, and a
**high score table** – turning a simple classic into a polished, replayable
experience.

## Tech
- Processing 4 (Java mode), multi-tab sketch, standard `size()` / `draw()` loop.
- Mouse (paddle follows mouse X) as primary control, with left/right arrow
  keys as an alternative.
- **Sound** – procedural PCM tones via the JDK's built-in `javax.sound.sampled`
  (see `Tone.pde`). No contributed library required.
- Built-in `PImage` for sprites; `loadStrings()`/`saveStrings()` for high score persistence.

## File Structure (each class in its own file)
- `brick_breaker.pde` — main sketch: `setup()`/`draw()`, game state machine
  (start/playing/game over/win/high score input), input handling, loading assets,
  top-level collision orchestration, level building.
- `GameState.pde` — state machine implementation: `StartState`, `PlayingState`,
  `WinningState`, `GameOverState`, `WinState`, `EnterHighScoreState`.
- `Paddle.pde` — `class Paddle` (position, movement/clamping, squash animation, drawing).
- `Ball.pde` — `class Ball` (position/velocity, movement, wall/paddle/brick
  bounce logic, ball trail with Arrays + Transformation, drawing).
- `Brick.pde` — `class Brick` (position, color/point value, multi‑hit support,
  death animation, hit test).
- `Physics.pde` — collision detection + physical response (reflection).
- `Effects.pde` — particle bursts + screen shake ("juice").
- `Particle.pde` — a single short‑lived burst particle.
- `PowerUp.pde` — `class PowerUp` (types: W, +, S, M; falling; paddle collision).
- `SoundManager.pde` — maps game events to pre-rendered tone clips.
- `Tone.pde` — zero-dependency PCM tone synthesizer and playback thread, built
  on `javax.sound.sampled`.
- `HighScore.pde` — high score management: top‑5, file I/O, display.
- `data/` — image assets (see below).

This satisfies the "at least 3 classes, each in its own file" requirement.

## Graphical Assets
Using the **"Breakout (Brick Breaker) Tile Set — Free"** pack by ImagineLabs
(imaginelabs.rocks), via OpenGameArt.org, licensed **CC0** (public domain —
free for personal/commercial use, no attribution required):
- Source: https://opengameart.org/content/breakout-brick-breaker-tile-set-free
- Verified download: CC0 license confirmed in the pack's `License.txt`.

Files to bring into `data/`, renamed for clarity:
| New name | Source file | Use |
|---|---|---|
| `ball.png` | `58-Breakout-Tiles.png` | the ball (shaded sphere sprite) |
| `paddle.png` | `55-Breakout-Tiles.png` | the paddle (metallic capsule sprite) |
| `brick_red.png` | `07-Breakout-Tiles.png` | brick row 1 (highest value) |
| `brick_orange.png` | `09-Breakout-Tiles.png` | brick row 2 |
| `brick_yellow.png` | `13-Breakout-Tiles.png` | brick row 3 |
| `brick_green.png` | `03-Breakout-Tiles.png` | brick row 4 |
| `brick_blue.png` | `01-Breakout-Tiles.png` | brick row 5 (lowest value) |

A short `data/ASSET_LICENSE.txt` records the source and CC0 license text.

## Core Gameplay

### Paddle
- Sprite‑drawn, near bottom of screen, moves horizontally, clamped to screen bounds.
- Squashes briefly when deflecting the ball (`pushMatrix()`/`scale()`).

### Ball
- Single main ball, with optional multi‑balls from power‑ups.
- Sprite‑drawn, constant speed, bounces off top/left/right walls, paddle, and bricks.
- Angle off paddle varies based on hit position (classic Breakout feel).
- **Ball trail**: fading ghost trail using `ArrayList<PVector>` + `pushMatrix()`/`rotate()`/`scale()`.

### Bricks
- Variable grid layout per level (4 levels with unique arrangements).
- **Normal bricks** (1 hit) and **hard bricks** (2 hits, displayed with a number).
- Sprite‑drawn using the 5 brick colors (row = color = point value).
- Death animation: fade‑and‑shrink (`pushMatrix()`/`scale()`).

### Power‑ups (20% drop chance on brick destruction)
| Icon | Name | Effect |
|------|------|--------|
| 🟦 **W** | Wider Paddle | Paddle width increases by 50% for 3 seconds. |
| 🟩 **+** | Extra Life | Gain one additional life. |
| 🟨 **S** | Slow Ball | Ball speed reduces by 30% for 3 seconds. |
| 🟪 **M** | Multi‑Ball | Spawns two extra balls with random upward directions. |

All balls break bricks; life is lost only when all balls are gone.

### Levels
- 4 levels with unique layouts:
  - Level 1: 4×6 all normal bricks.
  - Level 2: 5×8 with hard bricks on top/bottom.
  - Level 3: 5×8 checkerboard hard bricks.
  - Level 4: 6×8 all hard bricks.
- Current level displayed in HUD.

### Lives
- Player starts with 3 lives.
- Losing all balls costs a life and resets ball/paddle to starting position.
- Game over when lives reach 0.

### Win Condition
- Clearing all bricks in a level advances to the next level.
- Clearing all 4 levels shows a "You Win" screen.

### Score
- Normal brick: 20 points. Hard brick: 40 points.
- Score is displayed on the HUD.

### High Scores
- Top 5 scores saved to `scores.txt` in the sketch folder.
- Player enters initials (3 letters) when a new high score is achieved.
- High scores displayed on start, game over, and win screens.

### Sound Effects
- Paddle hit, brick hit, wall bounce, power‑up, level up, life lost, game over, win.
- Generated procedurally as PCM sine waves via the JDK's `javax.sound.sampled`
  (no external library) — see `Tone.pde`.
- A single-slot queue serializes playback so overlapping triggers don't cut
  each other off.

## Required Topics (this design covers all 3)
| Topic | Implementation |
|-------|----------------|
| **Arrays** | `Brick[][]` grid (2D array), `ArrayList<PowerUp>`, `ArrayList<Ball>` (multi‑ball), `ArrayList<HighScore>` (top‑5 scores), 3D `int[][][] levelData` for level layouts. |
| **Image Manipulation** | Paddle, ball, and bricks drawn from `PImage` sprites (`loadImage()`, `image()`), with `tint()` for trail ghosts. |
| **Transformation** | `pushMatrix()`/`popMatrix()` with `translate()`, `rotate()`, `scale()` for: ball trail ghosts, ball rotation, paddle squash, brick death animation. |

## Screens / States
1. **Start screen**: title + "click to start" prompt + high scores.
2. **Playing**: main gameplay.
3. **Winning**: brief transition while last brick's death animation finishes.
4. **Game Over**: shown on 0 lives, with final score and "click to restart".
5. **You Win!**: shown after completing all 4 levels, with score and "click to restart".
6. **New High Score**: overlay for entering initials when a top‑5 score is achieved.

## UI / HUD
- Score, level, and lives shown as text during play.
- High scores displayed on start, game over, and win screens.

## Explicitly Out of Scope (but added as extensions)
- ~~Power-ups, multiple balls, multiple levels, increasing difficulty.~~ — **ADDED**
- ~~Sound effects / music.~~ — **ADDED**
- ~~Saved high scores or config files.~~ — **ADDED**

## Deliverable
A Processing sketch folder (`brick_breaker/`) with all `.pde` files and a
`data/` folder of image assets, that runs as-is in the Processing IDE and is
playable start to finish (start → play → win/lose → restart → high scores).

## Version History
| Version | Changes |
|---------|---------|
| 1.0 (original) | Core Breakout mechanics, 5×8 bricks, start/play/game over/win screens. |
| 2.0 (extended) | Ball trail, 4 power‑ups (W, +, S, M), multi‑ball, 4 levels, sound effects, high score table. |
| 2.1 | Replaced the Processing Sound library dependency with a zero-dependency `javax.sound.sampled` tone synthesizer (`Tone.pde`); no contributed library required. |
