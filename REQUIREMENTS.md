# Brick Breaker — Requirements & Scope

## Overview
A Processing (Java mode) sketch implementing a classic brick breaker
(Breakout-style) game. Kept intentionally simple — one paddle, one ball, a grid
of bricks, score and lives, win/lose states.

## Tech
- Processing 3/4, multi-tab sketch, standard `size()` / `draw()` loop.
- Mouse (paddle follows mouse X) as primary control, with left/right arrow
  keys as an alternative.
- No external Processing libraries — built-in `PImage` only.

## File Structure (each class in its own file)
- `brick_breaker.pde` — main sketch: `setup()`/`draw()`, game state machine
  (start/playing/game over/win), input handling, loading assets, top-level
  collision orchestration.
- `Paddle.pde` — `class Paddle` (position, movement/clamping, drawing, collision rect).
- `Ball.pde` — `class Ball` (position/velocity, movement, wall/paddle/brick
  bounce logic, drawing).
- `Brick.pde` — `class Brick` (position, color/point value, alive flag, drawing,
  hit test).
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

A short `data/ASSET_LICENSE.txt` will record the source and CC0 license text.

## Core Gameplay
- **Paddle**: sprite-drawn, near bottom of screen, moves horizontally, clamped
  to screen bounds.
- **Ball**: single ball, sprite-drawn, constant speed, bounces off
  top/left/right walls, paddle, and bricks. Angle off paddle varies based on
  hit position (like classic Breakout).
- **Bricks**: fixed grid (e.g. 8 columns × 5 rows), sprite-drawn using the 5
  brick colors above (row = color = point value), each brick destroyed in one
  hit. No power-ups or multi-hit bricks.
- **Lives**: player starts with 3 lives. Losing the ball (falls below paddle)
  costs a life and resets ball/paddle to starting position. Game over when
  lives reach 0.
- **Win condition**: clearing all bricks shows a "You Win" screen.
- **Score**: increases per brick destroyed, displayed on screen.

## Required Topics (need ≥ 2 — this design covers all 3)
- **Arrays**: the brick grid is held in a 2D array (`Brick[][] bricks`),
  built/iterated with nested loops for layout, collision checks, and the
  win-condition (all-destroyed) check.
- **Image Manipulation**: paddle, ball, and bricks are drawn from `PImage`
  sprites (`image()`) loaded from `data/`, rather than primitive shapes.
- **Transformation**: the ball sprite rotates continuously in the direction
  of travel (`pushMatrix()`/`rotate()`/`popMatrix()`), and the paddle applies
  a brief `scale()` squash when it deflects the ball — small, purely visual
  touches on top of the core mechanics.

## Screens / States
1. **Start screen**: title + "click to start" prompt.
2. **Playing**: main gameplay.
3. **Game Over**: shown on 0 lives, with final score and "click to restart".
4. **Win**: shown when all bricks cleared, with score and "click to restart".

## UI / HUD
- Score and lives shown as simple text in a top corner during play.
- No menus, settings, sound, or persistence (no high-score saving).

## Explicitly Out of Scope
- Power-ups, multiple balls, multiple levels, increasing difficulty.
- Sound effects / music.
- Mobile/touch support.
- Saved high scores or config files.

## Deliverable
A Processing sketch folder (`brick_breaker/`) with the `.pde` files above and
a `data/` folder of image assets, that runs as-is in the Processing IDE and is
playable start to finish (start → play → win/lose → restart).
