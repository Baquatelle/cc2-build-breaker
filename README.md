# Brick Breaker

A fully-featured Breakout-style arcade game built in [Processing](https://processing.org/) (Java mode). Guide the ball with your paddle, smash bricks, collect power‑ups, conquer multiple levels, and compete for the high score.

![Processing](https://img.shields.io/badge/Processing-4-006699) ![License](https://img.shields.io/badge/assets-CC0-brightgreen) ![Sound](https://img.shields.io/badge/Sound-javax.sound.sampled-FF69B4)

---

## Table of Contents

- [What It Is](#what-it-is)
- [Features](#features)
- [Requirements](#requirements)
- [Getting Started](#getting-started)
- [How to Play](#how-to-play)
  - [Controls](#controls)
  - [Objective](#objective)
  - [Power‑ups](#power‑ups)
  - [Levels](#levels)
  - [Scoring & High Scores](#scoring--high-scores)
  - [Lives](#lives)
  - [Game Screens](#game-screens)
- [Gameplay Rules & Feel](#gameplay-rules--feel)
- [Project Structure](#project-structure)
- [Architecture Overview](#architecture-overview)
- [Configuration & Tuning](#configuration--tuning)
- [Assets & Licensing](#assets--licensing)
- [Troubleshooting](#troubleshooting)

---

## What It Is

Brick Breaker is a single‑player arcade game: one paddle, one ball (or more!), and a grid of bricks. Bounce the ball off the paddle to smash every brick without letting it fall past the bottom of the screen.

This version extends the classic formula with **power‑ups**, **multiple levels**, **multi‑ball**, **sound effects**, and a **high score table** – turning a simple classic into a polished, replayable experience.

The game runs as a Processing sketch, playable start to finish: start, play, advance through 4 levels, win or lose, and save your high score.

---

## Features

| Feature | Description |
|---------|-------------|
| 🏓 **Classic Breakout Mechanics** | Tight paddle deflection, ball physics, and screen shake. |
| 🎯 **Ball Trail** | Fading ghost trail behind the ball (uses Arrays + Transformation). |
| 💥 **Power‑ups** | Four types drop from bricks: **W**ider paddle, **+** Extra life, **S**low ball, **M**ulti‑ball. |
| 📈 **Multiple Levels** | 4 unique layouts with normal and hard (2‑hit) bricks. |
| 🎵 **Sound Effects** | Audio feedback for paddle hits, brick breaks, wall bounces, power‑ups, level ups, and game events. |
| 🏆 **High Score Table** | Top 5 scores saved to `scores.txt`; enter your initials on a new high score. |
| 💫 **Juice** | Particle bursts, screen shake, paddle squash, and brick death animations. |
| 🎮 **Mouse + Keyboard** | Move paddle with mouse or arrow keys (mix freely). |

---

## Requirements

- **[Processing 4](https://processing.org/download)** (Java mode). Processing 3 may work but is untested.

No other dependencies.

---

## Getting Started

1. **Install Processing** from [processing.org/download](https://processing.org/download).
2. **Clone or download** this repository.
3. **Open the sketch** – open `brick_breaker.pde` in the Processing IDE. All `.pde` files and the `data/` folder must be inside a folder named `brick_breaker/`.
4. **Run it** – press the Run button (▶) or `Ctrl/Cmd + R`. An 800×600 window opens on the start screen.
5. **Click** to start and play.

---

## How to Play

### Controls

| Action | Input |
|---|---|
| Move paddle | Move the mouse left/right (paddle follows mouse X) |
| Move paddle (alt) | Left / Right arrow keys |
| Start game | Click the mouse on the start screen |
| Restart after win/lose | Click the mouse |
| Enter high score initials | Type letters (A–Z), press `ENTER` to save, `BACKSPACE` to delete |

You can mix mouse and keyboard: while an arrow key is held the paddle moves at a fixed speed, otherwise it tracks the mouse.

### Objective

Destroy all bricks in each level by bouncing the ball into them. Keep the ball in play with the paddle. Advance through 4 increasingly difficult levels.

### Power‑ups

When you destroy a brick, there is a **20% chance** a power‑up will drop. Catch it with the paddle to activate:

| Icon | Name | Effect |
|------|------|--------|
| 🟦 **W** | Wider Paddle | Paddle width increases by 50% for 3 seconds. |
| 🟩 **+** | Extra Life | Gain one additional life. |
| 🟨 **S** | Slow Ball | Ball speed reduces by 30% for 3 seconds. |
| 🟪 **M** | Multi‑Ball | Spawns two extra balls with random upward directions. All balls break bricks; you lose a life only when all balls are gone. |

### Levels

There are **4 levels**, each with a unique brick layout:

| Level | Rows | Cols | Description |
|-------|------|------|-------------|
| 1 | 4 | 6 | Easy: all normal (1‑hit) bricks. |
| 2 | 5 | 8 | Hard bricks (2‑hit) on top and bottom rows. |
| 3 | 5 | 8 | Checkerboard pattern of hard bricks. |
| 4 | 6 | 8 | All hard bricks – the ultimate challenge. |

The current level is displayed in the HUD (top‑center).

### Scoring & High Scores

- **Brick points**: Normal bricks = 20 points; hard bricks = 40 points.
- **High Score Table**: Your score is saved if it ranks in the **top 5**. Enter your initials (up to 3 letters) when prompted. Scores persist between sessions via `scores.txt` in the sketch folder.

### Lives

- You start with **3 lives**, shown in the top‑right corner.
- You lose a life **only when all balls** (main + multi‑balls) have fallen off the screen.
- At 0 lives, the game ends.

### Game Screens

1. **Start** – Title screen with high scores displayed. Click to start.
2. **Playing** – Main game with HUD (score, level, lives).
3. **Winning** – Brief pause after clearing a level (bricks finish their death animation).
4. **Game Over** – Shown at 0 lives. Displays final score and high scores. Click to restart.
5. **You Win!** – Shown after completing all 4 levels. Displays score and high scores. Click to restart.
6. **New High Score** – Overlay for entering initials when a new top‑5 score is achieved.

---

## Gameplay Rules & Feel

- **Ball physics**: Constant speed; bounces off walls, paddle, and bricks. Sprite rotates in the direction of travel.
- **Ball trail**: A fading, shrinking ghost trail follows the ball – powered by an `ArrayList` of positions/angles and `pushMatrix()`/`popMatrix()` transforms.
- **Paddle deflection**: Classic Breakout angle – hit near center for straight bounce, near edges for sharper angles.
- **Brick health**: Normal bricks = 1 hit; hard bricks = 2 hits (display a number).
- **Juice**: Brick destruction spawns a colour‑matched particle burst, screen shake, and a fade‑shrink death animation. The paddle squashes on ball deflection.
- **Multi‑ball**: All balls break bricks and interact with the paddle. You only lose a life when every ball has fallen.

---

## Project Structure

Each class lives in its own file (Processing loads them as tabs of one sketch):

brick_breaker/
├── brick_breaker.pde # Main sketch: globals, setup(), draw(), HUD, input, helpers
├── GameState.pde # State machine: Start / Playing / Winning / GameOver / Win / EnterHighScore
├── Ball.pde # Ball: movement, bounce logic, trail (ArrayList + transformations)
├── Brick.pde # Brick: multi‑hit support, death animation, hit counter
├── Paddle.pde # Paddle: movement, clamping, squash animation
├── Physics.pde # Collision detection + physical response (reflection)
├── Effects.pde # Particle bursts + screen shake ("juice")
├── Particle.pde # A single short‑lived burst particle
├── PowerUp.pde # Power‑up: types (W, +, S, M), falling, paddle collision, display
├── SoundManager.pde # Maps game events to pre-rendered tone clips
├── Tone.pde # PCM tone synth + playback thread (javax.sound.sampled)
├── HighScore.pde # High score management: top‑5, file I/O, display
├── REQUIREMENTS.md # Original scope & requirements
├── README.md # This file
└── data/
├── ball.png
├── paddle.png
├── brick_red.png
├── brick_orange.png
├── brick_yellow.png
├── brick_green.png
├── brick_blue.png
└── ASSET_LICENSE.txt


---

## Architecture Overview

The code separates concerns into distinct layers:

- **`brick_breaker.pde` (game layer)**: Orchestrates the game loop. Holds globals (score, lives, level, balls, bricks, power‑ups). Each frame: updates paddle, updates all balls, resolves physics, applies consequences (score, bursts, power‑up spawn, win/life check), updates timers, and renders HUD.
- **`GameState.pde` (state machine)**: Each screen is a `GameState` subclass with `draw()`, `onClick()`, and `keyPressed()` (for high‑score input). Adding a state means adding one class and one array slot – no messy `if/else` chains.
- **`Physics.pde` (physics layer)**: Detects overlaps and applies physical responses (reflections). Owns no game rules – scoring, effects, and win/life logic stay in the game layer.
- **`Ball` / `Paddle` / `Brick` / `PowerUp`**: Each encapsulates its own state, behaviour, and drawing. The main tab translates input into a desired X for the paddle, keeping it decoupled from input sources.
- **`Effects` / `Particle`**: Own all visual "juice" (bursts and shake).
- **`SoundManager` / `Tone`**: `SoundManager` pre-renders one PCM clip per game event; `Tone` owns a daemon playback thread built on `javax.sound.sampled`, so triggering a sound from `draw()` is just a non-blocking queue push.
- **`HighScore`**: Manages top‑5 scores via `Comparable`, file I/O, and display.

**Required Processing topics covered:**

- **Arrays** (`ArrayList` for trails, power‑ups, multi‑balls; 3D `int[][][]` for level data; `ArrayList<HighScore>` for scores)
- **Transformation** (`pushMatrix()`/`popMatrix()` with `translate()`, `rotate()`, `scale()` for ball trail, paddle squash, brick death)
- **Image Manipulation** (`PImage`, `loadImage()`, `image()`, `tint()` for sprites and trail ghosts)

---

## Configuration & Tuning

Most gameplay values are `final` constants near the top of `brick_breaker.pde`:

| Constant | Meaning | Default |
|---|---|---|
| `BRICK_W`, `BRICK_H`, `BRICK_GAP` | Brick size and spacing | `90`, `30`, `4` |
| `BRICK_TOP` | Y of the top brick row | `60` |
| `BALL_RADIUS` | Ball size | `12` |
| `PADDLE_W`, `PADDLE_H`, `PADDLE_Y` | Paddle size and vertical position | `100`, `24`, `560` |
| `EFFECT_DURATION` | Duration of power‑up effects (frames) | `180` (~3s) |
| `MAX_LEVEL` | Number of levels | `4` |
| `WIN_DELAY` | Frames before win screen appears | `45` (~0.75s) |
| `SLOW_FACTOR` | Speed multiplier for slow ball | `0.7` |
| `DROP_RATE` | Power‑up drop chance per brick destruction | `0.2` (20%) |
| `WIDE_PADDLE_WIDTH` | Width when wider paddle is active | `150` |
| `POINTS_MULTIPLIER` | Base points per hit point | `20` |

Other knobs live with their classes:

- **Ball speed**: `Ball.launch()` sets initial velocity (`vx = ±3`, `vy = -4`).
- **Paddle speed**: `Paddle.speed` (keyboard movement, default `7`).
- **Squash animation**: `Paddle.SQUASH_FRAMES` and `scale()` factors in `Paddle.display()`.
- **Brick death**: `Brick.DEATH_FRAMES`.
- **Screen shake**: `Effects.SHAKE_DURATION`, `Effects.SHAKE_MAG`.
- **Particles**: Count in `Effects.burst()`; per‑particle speed/decay/size/gravity in `Particle`.
- **Starting lives**: `lives = 3` in `resetGame()`.
- **Level layouts**: Edit the `levelData` array in `brick_breaker.pde`.

---

## Assets & Licensing

**Sprites**: "Breakout (Brick Breaker) Tile Set - Free" by ImagineLabs ([imaginelabs.rocks](http://www.imaginelabs.rocks)), via [OpenGameArt.org](https://opengameart.org/content/breakout-brick-breaker-tile-set-free).  
Licensed [CC0](http://creativecommons.org/publicdomain/zero/1.0/) (public domain) – free for personal and commercial use, no attribution required. See [`data/ASSET_LICENSE.txt`](data/ASSET_LICENSE.txt) for full details.

**Sound**: Generated procedurally as PCM sine waves using the JDK's built-in `javax.sound.sampled` – no external audio files and no contributed library.

---

## Troubleshooting

| Issue | Solution |
|-------|----------|
| Blank file chooser dialog (Linux) | In Preferences, uncheck "Use native file selector". |
| Game doesn't start / black screen | Check the console for errors. Ensure all `.pde` files are in the sketch folder and the `data/` folder is present. |
| High scores not saving | Ensure the sketch folder is writable. The file `scores.txt` will be created automatically. |
| Multi‑balls don't break bricks | Check that `physics.resolveBricks()` is called for each ball in `updatePlaying()` – it should be. |
| Sound is silent | Check the console for a `Tone: audio unavailable` or `Tone: audio device kept failing` message – the game runs silently if no audio device is available, rather than crashing. Otherwise check your system audio output; `javax.sound.sampled` uses the default device. |

---

## Credits & Acknowledgments

- **Original architecture**: Teammate (s-01141) – built the core state machine, physics layer, and sprite rendering.
- **Feature extensions**: s-01123 – added ball trail, power‑ups, multi‑ball, multiple levels, sound effects, and high score table.
- **Assets**: ImagineLabs (OpenGameArt) – CC0 brick/paddle/ball sprites.

---

## License

**Code**: MIT License (or your choice – adjust as needed).  
**Assets**: CC0 (public domain).  
**Sound**: Procedural, no license restrictions.

---

*Enjoy the game! Feedback and contributions welcome.*

