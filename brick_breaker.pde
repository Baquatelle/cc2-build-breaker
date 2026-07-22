// Brick Breaker
// A simple Breakout-style game. See REQUIREMENTS.md for scope.

final int STATE_START = 0;
final int STATE_PLAYING = 1;
final int STATE_GAME_OVER = 2;
final int STATE_WINNING = 3;   // brief transition: let the last fade + burst finish
final int STATE_WIN = 4;
int state = STATE_START;
GameState[] states;

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
int[] rowPoints = { 50, 40, 30, 20, 10 };

Paddle paddle;
Ball ball;
Brick[][] bricks = new Brick[ROWS][COLS];

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
  effects = new Effects();

  states = new GameState[5];
  states[STATE_START]     = new StartState();
  states[STATE_PLAYING]   = new PlayingState();
  states[STATE_WINNING]   = new WinningState();
  states[STATE_GAME_OVER] = new GameOverState();
  states[STATE_WIN]       = new WinState();

  resetGame();
}

void draw() {
  background(20);
  states[state].draw();
}

void updatePlaying() {
  paddle.update(paddleTargetX());
  ball.update();

  // Paddle collision (only when ball moving downward)
  if (ball.hitsPaddle(paddle)) {
    ball.deflectOffPaddle(paddle);
    paddle.squash();
  }

  checkBrickCollisions();

  if (ball.isBelowScreen()) {
    lives--;
    if (lives <= 0) {
      state = STATE_GAME_OVER;
    } else {
      resetBallAndPaddle();
    }
  }
}

// Translate raw input (arrow keys, else mouse) into the paddle's desired
// left-edge X. Keeps input handling in the main tab, out of the Paddle class.
float paddleTargetX() {
  if (keyPressed && (keyCode == LEFT || keyCode == RIGHT)) {
    return paddle.x + (keyCode == LEFT ? -paddle.speed : paddle.speed);
  }
  return mouseX - paddle.w / 2;
}

void checkBrickCollisions() {
  for (int row = 0; row < ROWS; row++) {
    for (int col = 0; col < COLS; col++) {
      Brick b = bricks[row][col];
      if (b.collides(ball.x, ball.y, ball.r)) {
        b.destroy();
        score += b.points;
        effects.burst(b.x + b.w / 2, b.y + b.h / 2, rowColors[row]);

        ball.bounceOffBrick(b);

        if (allBricksDestroyed()) {
          state = STATE_WINNING;
          winTimer = WIN_DELAY;
        }
        return; // handle one brick hit per frame
      }
    }
  }
}

boolean allBricksDestroyed() {
  for (int row = 0; row < ROWS; row++) {
    for (int col = 0; col < COLS; col++) {
      if (bricks[row][col].alive) return false;
    }
  }
  return true;
}

void updateBricks() {
  for (int row = 0; row < ROWS; row++) {
    for (int col = 0; col < COLS; col++) {
      bricks[row][col].update();
    }
  }
}

void drawBricks() {
  for (int row = 0; row < ROWS; row++) {
    for (int col = 0; col < COLS; col++) {
      bricks[row][col].display();
    }
  }
}

void drawHUD() {
  fill(255);
  textSize(18);
  textAlign(LEFT, TOP);
  text("Score: " + score, 12, 10);
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

void resetGame() {
  score = 0;
  lives = 3;
  effects.clear();
  winTimer = 0;

  float totalWidth = COLS * (BRICK_W + BRICK_GAP) - BRICK_GAP;
  float offsetLeft = (width - totalWidth) / 2;

  for (int row = 0; row < ROWS; row++) {
    for (int col = 0; col < COLS; col++) {
      float bx = offsetLeft + col * (BRICK_W + BRICK_GAP);
      float by = BRICK_TOP + row * (BRICK_H + BRICK_GAP);
      bricks[row][col] = new Brick(bx, by, BRICK_W, BRICK_H, brickImgs[row], rowPoints[row]);
    }
  }

  resetBallAndPaddle();
}

void resetBallAndPaddle() {
  paddle.x = (width - paddle.w) / 2;
  ball.x = width / 2;
  ball.y = PADDLE_Y - BALL_RADIUS - 1;
  ball.launch();
}

void mousePressed() {
  states[state].onClick();
}
