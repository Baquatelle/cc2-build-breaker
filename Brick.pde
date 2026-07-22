class Brick {
  float x, y, w, h;
  PImage sprite;
  int points;
  boolean alive = true;

  // Death fade-out: plays after the brick is destroyed, under the burst.
  boolean dying = false;
  float deathTimer = 0;
  final float DEATH_FRAMES = 10;

  Brick(float bx, float by, float bw, float bh, PImage img, int pointValue) {
    x = bx;
    y = by;
    w = bw;
    h = bh;
    sprite = img;
    points = pointValue;
  }

  // Kill the brick: stop colliding/counting immediately, but start the fade.
  void destroy() {
    alive = false;
    dying = true;
    deathTimer = DEATH_FRAMES;
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
    if (alive) {
      image(sprite, x, y, w, h);
    } else if (dying) {
      float t = deathTimer / DEATH_FRAMES;   // 1.0 -> 0.0
      float s = 0.6 + 0.4 * t;                // shrink slightly toward 0.6
      pushMatrix();
      translate(x + w / 2, y + h / 2);
      scale(s);
      tint(255, 255 * t);                    // fade alpha out
      imageMode(CENTER);
      image(sprite, 0, 0, w, h);
      imageMode(CORNER);
      noTint();
      popMatrix();

      deathTimer--;
      if (deathTimer <= 0) dying = false;
    }
  }
}
