# Brick Breaker

A classic Breakout-style arcade game built as a [Processing](https://processing.org/) (Java mode) sketch. Guide the ball with your paddle, clear the grid of bricks, and rack up points. Sprite-based graphics, particle bursts, and screen shake give it some juice.

![Processing](https://img.shields.io/badge/Processing-3%2F4-006699) ![License](https://img.shields.io/badge/assets-CC0-brightgreen)

---

## Table of Contents

- [What It Is](#what-it-is)
- [Requirements](#requirements)
- [Getting Started](#getting-started)
- [How to Play](#how-to-play)
  - [Controls](#controls)
  - [Objective](#objective)
  - [Scoring](#scoring)
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

Brick Breaker is a single-player arcade game: one paddle, one ball, and a grid of 8 × 5 colored bricks. Bounce the ball off the paddle to smash every brick without letting it fall past the bottom of the screen. The game skips power-ups, extra balls, levels, and sound. It focuses on tight, polished core mechanics.

The game runs as a Processing sketch, playable start to finish: start, play, win or lose, restart.

---

## Requirements

- **[Processing 3 or 4](https://processing.org/download)** (Java mode) is the only dependency. No external Processing libraries are used, only the built-in `PImage` for sprites.

---

## Getting Started

1. **Install Processing** from [processing.org/download](https://processing.org/download).
2. **Open the sketch.** Open `brick_breaker.pde` in the Processing IDE. Processing sketches live in a folder named after the main tab, so keep all the `.pde` files and the `data/` folder together inside a folder named `brick_breaker/`. Processing loads every `.pde` file in that folder as a tab of the same sketch.
3. **Run it.** Press the Runs button in the Processing IDE, or press `Ctrl/Cmd + R`. An 800×600 window opens on the start screen.
4. **Click** to start and play.

---

## How to Play

### Controls

| Action | Input |
|---|---|
| Move paddle | Move the mouse left/right (paddle follows mouse X) |
| Move paddle (alt) | Left / Right arrow keys |
| Start game | Click the mouse on the start screen |
| Restart after win/lose | Click the mouse |

You can mix mouse and keyboard: while an arrow key is held the paddle moves at a fixed speed, otherwise it tracks the mouse.

### Objective

Destroy all 40 bricks (8 columns × 5 rows) by bouncing the ball into them. Keep the ball in play by deflecting it with the paddle each time it comes down.

### Scoring

Each brick's point value depends on its row (color). Higher rows are worth more:

| Row | Color | Points |
|---|---|---|
| 1 (top) | 🔴 Red | 50 |
| 2 | 🟠 Orange | 40 |
| 3 | 🟡 Yellow | 30 |
| 4 | 🟢 Green | 20 |
| 5 (bottom) | 🔵 Blue | 10 |

Clearing the whole board scores a maximum of 8 × (50+40+30+20+10) = 1200 points. The HUD shows your current score in the top-left corner during play.

### Lives

- You start with 3 lives, shown in the top-right corner.
- If the ball falls below the paddle, you lose a life, and the ball and paddle reset to their starting positions.
- At 0 lives, the game ends.

### Game Screens

1. **Start** - Title screen with a "Click to start" prompt. The board is previewed behind the overlay.
2. **Playing** - The main game with a live score/lives HUD.
3. **Game Over** - Shown at 0 lives, with your final score and a "Click to restart" prompt.
4. **You Win!** - Shown when every brick is cleared, with your score and a "Click to restart" prompt. A brief pause lets the last brick's destruction animation finish before this screen appears.

---

## Gameplay Rules & Feel

- **Ball physics**: The ball moves at a constant speed and bounces off the top, left, and right walls, the paddle, and bricks. The ball sprite rotates in the direction of travel.
- **Paddle deflection (classic Breakout angle)**: Where the ball strikes the paddle changes the outgoing angle. Hit near the center for a straight bounce, near an edge for a sharper one, so you can aim the ball.
- **One hit per brick**: A single hit destroys every brick. None are multi-hit or indestructible.
- **Juice**: Destroying a brick spawns a colored particle burst, triggers a short screen shake, and plays a fade-and-shrink death animation on the brick. The paddle squashes briefly when it deflects the ball.

---

## Project Structure

Each class lives in its own file (Processing loads them as tabs of one sketch):

```
brick_breaker/
├── brick_breaker.pde   # Main sketch: setup()/draw(), globals, state wiring,
│                       #   HUD, board layout, input translation, resets
├── GameState.pde       # State machine: Start / Playing / Winning / GameOver / Win
├── Paddle.pde          # Paddle: movement, clamping, squash animation, drawing
├── Ball.pde            # Ball: velocity, wall/paddle/brick bounce logic, drawing
├── Brick.pde           # Brick: position, points, hit test, death animation
├── Physics.pde         # Collision detection + physical response (reflection)
├── Effects.pde         # Particle bursts + screen shake ("juice")
├── Particle.pde        # A single short-lived burst particle
├── REQUIREMENTS.md     # Original scope & requirements
├── README.md           # This file
└── data/
    ├── ball.png        # Ball sprite
    ├── paddle.png      # Paddle sprite
    ├── brick_red.png   # Brick sprites, one per row/color
    ├── brick_orange.png
    ├── brick_yellow.png
    ├── brick_green.png
    ├── brick_blue.png
    └── ASSET_LICENSE.txt
```

---

## Architecture Overview

The code separates concerns so each piece stays reusable and testable:

- **`brick_breaker.pde` (game layer)**: Holds the globals (score, lives, ball, paddle, brick grid) and orchestrates each frame: update the paddle and ball, ask `Physics` to resolve collisions, then apply the game consequences (add score, spawn a burst, check for a win, or lose a life).
- **`GameState.pde` (state machine)**: Each screen is a small `GameState` subclass with its own `draw()` and `onClick()`. `draw()` and `mousePressed()` delegate to the current state, so adding a screen means adding a subclass and one array slot. Nothing else changes.
- **`Physics.pde` (physics layer)**: Detects overlaps and applies only the physical response (reflecting or repositioning the ball). It owns no game rules; scoring, effects, and win/lose detection stay in the game layer, which reacts to what physics reports.
- **`Ball` / `Paddle` / `Brick`**: Each encapsulates its own state and drawing. The ball owns its bounce math, the paddle owns its movement, clamping, and squash, and the brick owns its hit test and death animation. The main tab translates input (mouse vs. keys) into a desired X and passes it to the paddle, keeping the paddle decoupled from the input source.
- **`Effects` / `Particle`**: Own the visual juice (bursts and shake), kept out of the main tab.

This design covers the required Processing topics: arrays (the `Brick[][]` grid, built and iterated with nested loops), image manipulation (sprites drawn via `PImage`/`image()`), and transformation (`pushMatrix()`/`rotate()`/`scale()` for the spinning ball, squashing paddle, and shrinking bricks).

---

## Configuration & Tuning

Most gameplay values are `final` constants near the top of `brick_breaker.pde`, so you can tweak the feel without hunting through the code:

| Constant | Meaning | Default |
|---|---|---|
| `COLS`, `ROWS` | Brick grid dimensions | `8`, `5` |
| `BRICK_W`, `BRICK_H`, `BRICK_GAP` | Brick size and spacing | `90`, `30`, `4` |
| `BRICK_TOP` | Y of the top brick row | `60` |
| `BALL_RADIUS` | Ball size | `12` |
| `PADDLE_W`, `PADDLE_H`, `PADDLE_Y` | Paddle size and vertical position | `100`, `24`, `560` |
| `rowPoints[]` | Points per row (top → bottom) | `{50, 40, 30, 20, 10}` |
| `WIN_DELAY` | Frames before the win screen appears | `45` (~0.75s) |

Other knobs live with their classes:

- **Ball speed**: `Ball.launch()` sets the initial velocity (`vx = ±3`, `vy = -4`).
- **Paddle speed**: `Paddle.speed` (keyboard movement, default `7`).
- **Squash strength/length**: `Paddle.SQUASH_FRAMES` and the `scale()` factors in `Paddle.display()`.
- **Brick death animation**: `Brick.DEATH_FRAMES`.
- **Screen shake**: `Effects.SHAKE_DURATION`, `Effects.SHAKE_MAG`.
- **Particles**: count in `Effects.burst()`; per-particle speed/decay/size/gravity in `Particle`.
- **Starting lives**: set in `resetGame()` (`lives = 3`).

---

## Assets & Licensing

The sprites come from the "Breakout (Brick Breaker) Tile Set - Free" pack by ImagineLabs ([imaginelabs.rocks](http://www.imaginelabs.rocks)), via [OpenGameArt.org](https://opengameart.org/content/breakout-brick-breaker-tile-set-free).

They're licensed [CC0](http://creativecommons.org/publicdomain/zero/1.0/) (public domain): free for personal and commercial use, no attribution required. See [`data/ASSET_LICENSE.txt`](data/ASSET_LICENSE.txt) for the original filename mapping and full license note.
