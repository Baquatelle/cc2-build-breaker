// Brick Breaker
// A simple Breakout-style game with power-ups, levels, sound, and high scores.

// State constants
final int STATE_START = 0;
final int STATE_PLAYING = 1;
final int STATE_GAME_OVER = 2;
final int STATE_WINNING = 3;   // brief transition: let the last fade + burst finish
final int STATE_WIN = 4;
final int STATE_ENTER_HIGH_SCORE = 5;
int state = STATE_START;
GameState[] states;

// Level progression
int level = 1;
final int MAX_LEVEL = 4;

// Timing
float winTimer = 0;
final float WIN_DELAY = 45;     // ~0.75s at 60fps

// Brick layout constants
final float BRICK_W = 90;
final float BRICK_H = 30;
final float BRICK_GAP = 4;
final float BRICK_TOP = 60;

// Ball & paddle constants
final float BALL_RADIUS = 12;
final float PADDLE_W = 100;
final float PADDLE_H = 24;
final float PADDLE_Y = 560;

// Gameplay constants
final float SLOW_FACTOR = 0.7;
final float DROP_RATE = 0.2;
final float WIDE_PADDLE_WIDTH = 150;
final int POINTS_MULTIPLIER = 20;
final int EFFECT_DURATION = 180;   // 3 seconds at 60fps

// Sprites
PImage ballImg, paddleImg;
PImage[] brickImgs = new PImage[5];

// Game objects
Paddle paddle;
ArrayList<Ball> balls = new ArrayList<Ball>();  // unified ball list (main + multi)
Brick[][] bricks;
Physics physics;

// Game state
int score = 0;
int lives = 3;

// Visual effects
Effects effects;
color[] rowColors = {
  color(220, 60, 50),    // red
  color(230, 130, 40),   // orange
  color(235, 205, 55),   // yellow
  color(70, 190, 80),    // green
  color(60, 130, 220)    // blue
};

// Power-ups
ArrayList<PowerUp> powerups = new ArrayList<PowerUp>();
int wideTimer = 0;
int slowTimer = 0;

// Sound
SoundManager sound;

// High score input (globals used by EnterHighScoreState)
String newHighScoreName = "";
int tempScore = 0;

// Level layouts: [level][row][col]  (0=empty, 1=normal, 2=hard)
int[][][] levelData = {
  // Level 1: 4x6
  {
    {1,1,1,1,1,1},
    {1,1,1,1,1,1},
    {1,1,1,1,1,1},
    {1,1,1,1,1,1}
  },
  // Level 2: 5x8 with hard top/bottom
  {
    {2,2,2,2,2,2,2,2},
    {1,1,1,1,1,1,1,1},
    {1,1,1,1,1,1,1,1},
    {1,1,1,1,1,1,1,1},
    {2,2,2,2,2,2,2,2}
  },
  // Level 3: checkerboard hard
  {
    {2,1,2,1,2,1,2,1},
    {1,2,1,2,1,2,1,2},
    {2,1,2,1,2,1,2,1},
    {1,2,1,2,1,2,1,2},
    {2,1,2,1,2,1,2,1}
  },
  // Level 4: all hard 6x8
  {
    {2,2,2,2,2,2,2,2},
    {2,2,2,2,2,2,2,2},
    {2,2,2,2,2,2,2,2},
    {2,2,2,2,2,2,2,2},
    {2,2,2,2,2,2,2,2},
    {2,2,2,2,2,2,2,2}
  }
};

// ============== SETUP =======================

void setup() {
  size(800, 600);
  imageMode(CORNER);

  // Load images
  ballImg = loadImage("ball.png");
  paddleImg = loadImage("paddle.png");
  brickImgs[0] = loadImage("brick_red.png");
  brickImgs[1] = loadImage("brick_orange.png");
  brickImgs[2] = loadImage("brick_yellow.png");
  brickImgs[3] = loadImage("brick_green.png");
  brickImgs[4] = loadImage("brick_blue.png");

  paddle = new Paddle((width - PADDLE_W) / 2, PADDLE_Y, PADDLE_W, PADDLE_H, paddleImg);
  effects = new Effects();
  physics = new Physics();

  // Initialize Sound Manager
  sound = new SoundManager();

  loadHighScores();

  states = new GameState[6];
  states[STATE_START]              = new StartState();
  states[STATE_PLAYING]            = new PlayingState();
  states[STATE_WINNING]            = new WinningState();
  states[STATE_GAME_OVER]          = new GameOverState();
  states[STATE_WIN]                = new WinState();
  states[STATE_ENTER_HIGH_SCORE]   = new EnterHighScoreState();

  resetGame();
}

void draw() {
  background(20);
  states[state].draw();
}

// =============== GAME LOGIC ====================

void updatePlaying() {
  // Update paddle
  paddle.update(paddleTargetX());

  // Update all balls
  for (int i = balls.size()-1; i >= 0; i--) {
    Ball b = balls.get(i);
    b.update();
    // Remove if fallen off screen
    if (b.isBelowScreen()) {
      balls.remove(i);
      continue;
    }
    // Paddle collision
    if (physics.resolvePaddle(b, paddle)) {
      paddle.squash();
      sound.paddleHit();
    }
    // Brick collisions
    Brick hit = physics.resolveBricks(b, bricks);
    if (hit != null) {
      boolean destroyed = hit.hit();   // returns true if brick died
      if (destroyed) {
        processBrickHit(hit);
      }
    }
  }

  // Check win condition (all bricks destroyed)
  if (allBricksDestroyed()) {
    if (level >= MAX_LEVEL) {
      // Check high score before showing win screen
      if (isHighScore(score)) {
        tempScore = score;
        newHighScoreName = "";
        state = STATE_ENTER_HIGH_SCORE;
        sound.win();
      } else {
        state = STATE_WIN;
        sound.win();
      }
    } else {
      level++;
      sound.levelUp();
      buildLevel(level);
      resetBalls();
      powerups.clear();
    }
  }

  // Update power-ups
  for (int i = powerups.size()-1; i >= 0; i--) {
    PowerUp p = powerups.get(i);
    p.update();
    if (p.hitsPaddle(paddle)) {
      applyPowerUp(p.type);
      powerups.remove(i);
    } else if (!p.active) {
      powerups.remove(i);
    }
  }

  // Update timers
  if (wideTimer > 0) {
    wideTimer--;
    if (wideTimer == 0) paddle.w = PADDLE_W;
  }
  if (slowTimer > 0) {
    slowTimer--;
    if (slowTimer == 0) {
      // Restore speed for all balls
      for (Ball b : balls) {
        b.vx /= SLOW_FACTOR;
        b.vy /= SLOW_FACTOR;
      }
    }
  }

  // Check life loss – only when no balls remain
  if (balls.isEmpty()) {
    lives--;
    if (lives <= 0) {
      sound.gameOver();
      if (isHighScore(score)) {
        tempScore = score;
        newHighScoreName = "";
        state = STATE_ENTER_HIGH_SCORE;
      } else {
        state = STATE_GAME_OVER;
      }
    } else {
      sound.lifeLost();
      resetBalls();
    }
  }
}

void processBrickHit(Brick hit) {
  if (hit == null) return;
  score += hit.points;
  sound.brickHit();
  effects.burst(hit.x + hit.w/2, hit.y + hit.h/2, hit.burstColor);
  
  if (random(1) < DROP_RATE) {
    int type = (int) random(4);
    powerups.add(new PowerUp(hit.x + hit.w/2, hit.y + hit.h/2, type));
  }
}

void applyPowerUp(int type) {
  switch(type) {
    case PowerUp.WIDER:
      paddle.w = WIDE_PADDLE_WIDTH;
      wideTimer = EFFECT_DURATION;
      sound.powerUp();
      break;
    case PowerUp.EXTRA_LIFE:
      lives++;
      sound.powerUp();
      break;
    case PowerUp.SLOW_BALL:
      for (Ball b : balls) {
        b.vx *= SLOW_FACTOR;
        b.vy *= SLOW_FACTOR;
      }
      slowTimer = EFFECT_DURATION;
      sound.powerUp();
      break;
    case PowerUp.MULTI_BALL:
      if (!balls.isEmpty()) {
        Ball ref = balls.get(0);
        for (int i = 0; i < 2; i++) {
          Ball nb = new Ball(ref.x, ref.y, ref.r, ballImg);
          // Upward cone: between -60 and +60 degrees from straight up
          float angle = random(-PI/3, PI/3) - PI/2;
          float spd = sqrt(ref.vx*ref.vx + ref.vy*ref.vy);
          if (spd < 1) spd = 4;
          nb.vx = cos(angle) * spd;
          nb.vy = sin(angle) * spd;
          balls.add(nb);
        }
        sound.powerUp();
      }
      break;
  }
}

void resetBalls() {
  balls.clear();
  Ball main = new Ball(width/2, PADDLE_Y - BALL_RADIUS - 1, BALL_RADIUS, ballImg);
  main.launch();
  balls.add(main);
}

// Translate raw input (arrow keys, else mouse) into the paddle's desired
// left-edge X. Keeps input handling in the main tab, out of the Paddle class.
float paddleTargetX() {
  if (keyPressed && (keyCode == LEFT || keyCode == RIGHT)) {
    return paddle.x + (keyCode == LEFT ? -paddle.speed : paddle.speed);
  }
  return mouseX - paddle.w / 2;
}

boolean allBricksDestroyed() {
  for (int r = 0; r < bricks.length; r++) {
    for (int c = 0; c < bricks[r].length; c++) {
      if (bricks[r][c].alive) return false;
    }
  }
  return true;
}

void updateBricks() {
  for (int r = 0; r < bricks.length; r++) {
    for (int c = 0; c < bricks[r].length; c++) {
      bricks[r][c].update();
    }
  }
}

void drawBricks() {
  for (int r = 0; r < bricks.length; r++) {
    for (int c = 0; c < bricks[r].length; c++) {
      bricks[r][c].display();
    }
  }
}

void drawHUD() {
  fill(255);
  textSize(18);
  textAlign(LEFT, TOP);
  text("Score: " + score, 12, 10);
  textAlign(CENTER, TOP);
  text("Level: " + level, width/2, 10);
  textAlign(RIGHT, TOP);
  text("Lives: " + lives, width - 12, 10);
}

void drawCenteredScreen(String title, String subtitle) {
  fill(0, 160);
  rect(0, 0, width, height);
  fill(255);
  textAlign(CENTER, CENTER);
  textSize(48);
  text(title, width / 2, height / 2 - 20);
  textSize(20);
  text(subtitle, width / 2, height / 2 + 30);
}

// ================= LEVEL BUILDING ================

void resetGame() {
  score = 0;
  lives = 3;
  effects.clear();
  winTimer = 0;
  level = 1;
  powerups.clear();
  wideTimer = 0;
  slowTimer = 0;
  paddle.w = PADDLE_W;   // RESET WIDE PADDLE
  buildLevel(level);
  resetBalls();
}

void buildLevel(int lvl) {
  int index = lvl - 1;   // 0-based, safe because lvl <= MAX_LEVEL
  int rows = levelData[index].length;
  int cols = levelData[index][0].length;
  
  bricks = new Brick[rows][cols];
  
  float totalWidth = cols * (BRICK_W + BRICK_GAP) - BRICK_GAP;
  float offsetLeft = (width - totalWidth) / 2;
  
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      int hp = levelData[index][r][c];
      if (hp > 0) {
        float bx = offsetLeft + c * (BRICK_W + BRICK_GAP);
        float by = BRICK_TOP + r * (BRICK_H + BRICK_GAP);
        int pts = hp * POINTS_MULTIPLIER;
        color col = rowColors[r % rowColors.length];
        PImage img = brickImgs[r % brickImgs.length];
        bricks[r][c] = new Brick(bx, by, BRICK_W, BRICK_H, img, pts, col, hp);
      } else {
        // dummy brick, alive = false
        bricks[r][c] = new Brick(0, 0, 0, 0, null, 0, color(0), 0);
        bricks[r][c].alive = false;
      }
    }
  }
}

// ===================== INPUT ====================

void mousePressed() {
  states[state].onClick();
}

void keyPressed() {
  if (state == STATE_ENTER_HIGH_SCORE) {
    states[state].keyPressed();
  }
}
