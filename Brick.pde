class Brick {
  float x, y, w, h;
  PImage sprite;
  int points;
  color burstColor;   // color of the particle burst when destroyed
  boolean alive = true;

  // Death fade-out: plays after the brick is destroyed, under the burst.
  boolean dying = false;
  float deathTimer = 0;
  final float DEATH_FRAMES = 6;

  Brick(float bx, float by, float bw, float bh, PImage img, int pointValue, color burstCol) {
    x = bx;
    y = by;
    w = bw;
    h = bh;
    sprite = img;
    points = pointValue;
    burstColor = burstCol;
  }

  // Kill the brick: stop colliding/counting immediately, but start the fade.
  void destroy() {
    alive = false;
    dying = true;
    deathTimer = DEATH_FRAMES;
  }

  // Advance the death fade-out animation. Kept separate from display() so
  // rendering stays side-effect free (one update per frame, regardless of draws).
  void update() {
    if (dying) {
      deathTimer--;
      if (deathTimer <= 0) dying = false;
    }
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
      float s = 0.3 + 0.7 * t;                // collapse crisply toward 0.3
      pushMatrix();
      translate(x + w / 2, y + h / 2);
      scale(s);
      tint(255, 255 * t * t);                // eased fade -> snappy pop-out
      imageMode(CENTER);
      image(sprite, 0, 0, w, h);
      imageMode(CORNER);
      noTint();
      popMatrix();
    }
  }
}
