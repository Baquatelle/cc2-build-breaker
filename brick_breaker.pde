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

void setup() {
  size(800, 600);
  imageMode(CORNER);
}

void draw() {
  background(20);
}
