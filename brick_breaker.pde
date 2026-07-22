// Brick Breaker
// A simple Breakout-style game. See REQUIREMENTS.md for scope.

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

  resetGame();
}

void draw() {
  background(20);
  paddle.update();
  ball.update();

  // Paddle collision (only when ball moving downward)
  if (ball.vy > 0
      && ball.x + ball.r > paddle.x && ball.x - ball.r < paddle.x + paddle.w
      && ball.y + ball.r > paddle.y && ball.y - ball.r < paddle.y + paddle.h) {
    ball.y = paddle.y - ball.r;
    float relativeIntersect = (ball.x - (paddle.x + paddle.w / 2)) / (paddle.w / 2);
    relativeIntersect = constrain(relativeIntersect, -1, 1);
    float speed = sqrt(ball.vx * ball.vx + ball.vy * ball.vy);
    ball.vx = relativeIntersect * speed;
    ball.vy = -sqrt(max(speed * speed - ball.vx * ball.vx, speed * speed * 0.3));
  }

  checkBrickCollisions();

  if (ball.isBelowScreen()) {
    lives--;
    if (lives <= 0) {
      resetGame();
    } else {
      resetBallAndPaddle();
    }
  }

  drawBricks();
  paddle.display();
  ball.display();
}

void checkBrickCollisions() {
  for (int row = 0; row < ROWS; row++) {
    for (int col = 0; col < COLS; col++) {
      Brick b = bricks[row][col];
      if (b.collides(ball.x, ball.y, ball.r)) {
        b.alive = false;
        score += b.points;

        boolean wasAboveOrBelow = (ball.prevY + ball.r <= b.y) || (ball.prevY - ball.r >= b.y + b.h);
        boolean wasLeftOrRight = (ball.prevX + ball.r <= b.x) || (ball.prevX - ball.r >= b.x + b.w);
        if (wasAboveOrBelow) {
          ball.vy = -ball.vy;
        } else if (wasLeftOrRight) {
          ball.vx = -ball.vx;
        } else {
          ball.vy = -ball.vy;
        }
        return; // handle one brick hit per frame
      }
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

void resetGame() {
  score = 0;
  lives = 3;

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
