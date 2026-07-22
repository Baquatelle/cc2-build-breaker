class Brick {
  float x, y, w, h;
  PImage sprite;
  int points;
  boolean alive = true;

  Brick(float bx, float by, float bw, float bh, PImage img, int pointValue) {
    x = bx;
    y = by;
    w = bw;
    h = bh;
    sprite = img;
    points = pointValue;
  }

  boolean collides(float ballX, float ballY, float ballR) {
    if (!alive) return false;
    float closestX = constrain(ballX, x, x + w);
    float closestY = constrain(ballY, y, y + h);
    float dx = ballX - closestX;
    float dy = ballY - closestY;
    return (dx * dx + dy * dy) < ballR * ballR;
  }

  void display() {
    if (!alive) return;
    image(sprite, x, y, w, h);
  }
}
