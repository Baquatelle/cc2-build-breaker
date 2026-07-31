import processing.sound.*;

// Brick Breaker
// A simple Breakout-style game. See REQUIREMENTS.md for scope.

final int STATE_START = 0;
final int STATE_PLAYING = 1;
final int STATE_GAME_OVER = 2;
final int STATE_WINNING = 3;   // brief transition: let the last fade + burst finish
final int STATE_WIN = 4;
final int STATE_ENTER_HIGH_SCORE = 5;   // High Score input state
int state = STATE_START;
GameState[] states;
int level = 1;
final int MAX_LEVEL = 4;

float winTimer = 0;
final float WIN_DELAY = 45;     // ~0.75s at 60fps

final int COLS = 8;
final int ROWS = 5;
final float BRICK_W = 90;
final float BRICK_H = 30;
final float BRICK_GAP = 4;
final float BRICK_TOP = 60;

final float BALL_RADIUS = 12;
final float PADDLE_W = 100;
final float PADDLE_H = 24;
final float PADDLE_Y = 560;

PImage ballImg, paddleImg;
PImage[] brickImgs = new PImage[ROWS];

Paddle paddle;
Ball ball;
Brick[][] bricks = new Brick[ROWS][COLS];
Physics physics;

int score = 0;
int lives = 3;

// Juice: brick-destruction particle burst + screen shake, owned by Effects.
Effects effects;
color[] rowColors = {
  color(220, 60, 50),    // red
  color(230, 130, 40),   // orange
  color(235, 205, 55),   // yellow
  color(70, 190, 80),    // green
  color(60, 130, 220)    // blue
};

// Power-up globals
ArrayList<PowerUp> powerups = new ArrayList<PowerUp>();
ArrayList<Ball> multiBalls = new ArrayList<Ball>();
int wideTimer = 0;
int slowTimer = 0;
final int EFFECT_DURATION = 180;   // 3 seconds at 60fps

// Sound Manager (global)
SoundManager sound;

// High Score globals
String newHighScoreName = "";
int tempScore = 0;

// Level layouts: [level][row][col]
// 0 = empty, 1 = normal brick, 2 = hard brick
int[][][] levelData = {
  // Level 1: 4 rows x 6 columns (easy to clear)
  {
    {1,1,1,1,1,1},
    {1,1,1,1,1,1},
    {1,1,1,1,1,1},
    {1,1,1,1,1,1}
  },
  // Level 2: 5 rows x 8 columns, hard bricks on top & bottom
  {
    {2,2,2,2,2,2,2,2},
    {1,1,1,1,1,1,1,1},
    {1,1,1,1,1,1,1,1},
    {1,1,1,1,1,1,1,1},
    {2,2,2,2,2,2,2,2}
  },
  // Level 3: checkerboard pattern of hard bricks
  {
    {2,1,2,1,2,1,2,1},
    {1,2,1,2,1,2,1,2},
    {2,1,2,1,2,1,2,1},
    {1,2,1,2,1,2,1,2},
    {2,1,2,1,2,1,2,1}
  },
  // Level 4: all hard bricks, 6 rows
  {
    {2,2,2,2,2,2,2,2},
    {2,2,2,2,2,2,2,2},
    {2,2,2,2,2,2,2,2},
    {2,2,2,2,2,2,2,2},
    {2,2,2,2,2,2,2,2},
    {2,2,2,2,2,2,2,2}
  }
};

void setup() {
  size(800, 600);
  imageMode(CORNER);

  ballImg = loadImage("ball.png");
  paddleImg = loadImage("paddle.png");
  brickImgs[0] = loadImage("brick_red.png");
  brickImgs[1] = loadImage("brick_orange.png");
  brickImgs[2] = loadImage("brick_yellow.png");
  brickImgs[3] = loadImage("brick_green.png");
  brickImgs[4] = loadImage("brick_blue.png");

  paddle = new Paddle((width - PADDLE_W) / 2, PADDLE_Y, PADDLE_W, PADDLE_H, paddleImg);
  ball = new Ball(0, 0, BALL_RADIUS, ballImg);
  ball.isMain = true;
  effects = new Effects();
  physics = new Physics();

  // Initialize Sound Manager
  sound = new SoundManager(this);

  // Load high scores from file
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
  // Update sound timers
  if (sound != null) sound.update();
  states[state].draw();
}

void updatePlaying() {
  // Update paddle
  paddle.update(paddleTargetX());

  // Update main ball
  ball.update();

  // Update multi-balls
  for (int i = multiBalls.size()-1; i >= 0; i--) {
    Ball mb = multiBalls.get(i);
    mb.update();
    if (physics.resolvePaddle(mb, paddle)) {
      paddle.squash();
      sound.paddleHit();
    }
    if (mb.isBelowScreen()) {
      multiBalls.remove(i);
    }
  }

  // Paddle collision for main ball
  if (physics.resolvePaddle(ball, paddle)) {
    paddle.squash();
    sound.paddleHit();
  }

  // Brick collisions for ALL balls
  boolean anyBrickHit = false;
  Brick hit;
  
  hit = physics.resolveBricks(ball, bricks);
  if (hit != null) {
    processBrickHit(hit);
    anyBrickHit = true;
  }
  
  for (Ball mb : multiBalls) {
    hit = physics.resolveBricks(mb, bricks);
    if (hit != null) {
      processBrickHit(hit);
      anyBrickHit = true;
    }
  }

  // Check win condition
  if (anyBrickHit && allBricksDestroyed()) {
    level++;
    if (level > MAX_LEVEL) {
      // Check for high score before showing win screen
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
      sound.levelUp();
      buildLevel(level);
      resetBallAndPaddle();
      powerups.clear();
      multiBalls.clear();
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
  }

  // Check if any ball is still alive
  boolean anyAlive = !ball.isBelowScreen();
  for (Ball mb : multiBalls) {
    if (!mb.isBelowScreen()) anyAlive = true;
  }

  if (!anyAlive) {
    lives--;
    if (lives <= 0) {
      sound.gameOver();
      // Check for high score
      if (isHighScore(score)) {
        tempScore = score;
        newHighScoreName = "";
        state = STATE_ENTER_HIGH_SCORE;
      } else {
        state = STATE_GAME_OVER;
      }
    } else {
      sound.lifeLost();
      resetBallAndPaddle();
      multiBalls.clear();
    }
  }
}

float paddleTargetX() {
  if (keyPressed && (keyCode == LEFT || keyCode == RIGHT)) {
    return paddle.x + (keyCode == LEFT ? -paddle.speed : paddle.speed);
  }
  return mouseX - paddle.w / 2;
}

boolean allBricksDestroyed() {
  for (int row = 0; row < bricks.length; row++) {
    for (int col = 0; col < bricks[row].length; col++) {
      if (bricks[row][col].alive) return false;
    }
  }
  return true;
}

void updateBricks() {
  for (int row = 0; row < bricks.length; row++) {
    for (int col = 0; col < bricks[row].length; col++) {
      bricks[row][col].update();
    }
  }
}

void drawBricks() {
  for (int row = 0; row < bricks.length; row++) {
    for (int col = 0; col < bricks[row].length; col++) {
      bricks[row][col].display();
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

void applyPowerUp(int type) {
  switch(type) {
    case PowerUp.WIDER:
      paddle.w = 150;
      wideTimer = EFFECT_DURATION;
      sound.powerUp();
      break;
    case PowerUp.EXTRA_LIFE:
      lives++;
      sound.powerUp();
      break;
    case PowerUp.SLOW_BALL:
      float speed = sqrt(ball.vx*ball.vx + ball.vy*ball.vy);
      if (speed > 1) {
        ball.vx *= 0.7;
        ball.vy *= 0.7;
      }
      slowTimer = EFFECT_DURATION;
      sound.powerUp();
      break;
    case PowerUp.MULTI_BALL:
      for (int i = 0; i < 2; i++) {
        Ball nb = new Ball(ball.x, ball.y, ball.r, ballImg);
        float angle = random(TWO_PI);
        float spd = sqrt(ball.vx*ball.vx + ball.vy*ball.vy);
        nb.vx = cos(angle) * spd;
        nb.vy = sin(angle) * spd;
        multiBalls.add(nb);
      }
      sound.powerUp();
      break;
  }
}

void processBrickHit(Brick hit) {
  if (hit == null) return;
  hit.destroy();
  score += hit.points;
  sound.brickHit();
  effects.burst(hit.x + hit.w/2, hit.y + hit.h/2, hit.burstColor);
  
  if (random(1) < 0.2) {
    int type = (int) random(4);
    powerups.add(new PowerUp(hit.x + hit.w/2, hit.y + hit.h/2, type));
  }
}

void resetGame() {
  score = 0;
  lives = 3;
  effects.clear();
  winTimer = 0;
  level = 1;
  powerups.clear();
  multiBalls.clear();
  wideTimer = 0;
  slowTimer = 0;
  buildLevel(level);
  resetBallAndPaddle();
}

void buildLevel(int lvl) {
  int index = (lvl - 1) % levelData.length;
  int rows = levelData[index].length;
  int cols = levelData[index][0].length;
  
  bricks = new Brick[rows][cols];
  
  float totalWidth = cols * (BRICK_W + BRICK_GAP) - BRICK_GAP;
  float offsetLeft = (width - totalWidth) / 2;
  
  for (int r = 0; r < rows; r++) {
    for (int c = 0; c < cols; c++) {
      int hitPoints = levelData[index][r][c];
      if (hitPoints > 0) {
        float bx = offsetLeft + c * (BRICK_W + BRICK_GAP);
        float by = BRICK_TOP + r * (BRICK_H + BRICK_GAP);
        int points = hitPoints * 20;
        color col = rowColors[r % rowColors.length];
        PImage img = brickImgs[r % brickImgs.length];
        bricks[r][c] = new Brick(bx, by, BRICK_W, BRICK_H, img, points, col, hitPoints);
      } else {
        bricks[r][c] = new Brick(0, 0, 0, 0, null, 0, color(0), 0);
        bricks[r][c].alive = false;
      }
    }
  }
}

void resetBallAndPaddle() {
  paddle.x = (width - paddle.w) / 2;
  ball.x = width / 2;
  ball.y = PADDLE_Y - BALL_RADIUS - 1;
  ball.launch();
  multiBalls.clear();
}

void mousePressed() {
  states[state].onClick();
}

// Key handling for high score input
void keyPressed() {
  if (state == STATE_ENTER_HIGH_SCORE) {
    states[state].keyPressed();
  }
}
