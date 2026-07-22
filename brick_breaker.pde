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
Paddle paddle;
Ball ball;

void setup() {
  size(800, 600);
  imageMode(CORNER);

  ballImg = loadImage("ball.png");
  paddleImg = loadImage("paddle.png");

  paddle = new Paddle((width - PADDLE_W) / 2, PADDLE_Y, PADDLE_W, PADDLE_H, paddleImg);
  ball = new Ball(width / 2, PADDLE_Y - BALL_RADIUS - 1, BALL_RADIUS, ballImg);
  ball.launch();
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

  paddle.display();
  ball.display();
}
