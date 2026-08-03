class Brick {
  float x, y, w, h;
  PImage sprite;
  int points;
  color burstColor;
  boolean alive = true;
  
  int maxHits = 1;
  int hitsRemaining = 1;

  boolean dying = false;
  float deathTimer = 0;
  final float DEATH_FRAMES = 6;

  Brick(float bx, float by, float bw, float bh, PImage img, int pointValue, color burstCol) {
    this(bx, by, bw, bh, img, pointValue, burstCol, 1);
  }

  Brick(float bx, float by, float bw, float bh, PImage img, int pointValue, color burstCol, int hits) {
    x = bx;
    y = by;
    w = bw;
    h = bh;
    sprite = img;
    points = pointValue;
    burstColor = burstCol;
    maxHits = hits;
    hitsRemaining = hits;
    alive = (hits > 0);
  }

  // Returns true if the brick was destroyed on this hit
  boolean hit() {
    if (!alive) return false;
    hitsRemaining--;
    if (hitsRemaining <= 0) {
      alive = false;
      dying = true;
      deathTimer = DEATH_FRAMES;
      return true;
    }
    return false;
  }

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
      if (maxHits > 1) {
        fill(255);
        textAlign(CENTER, CENTER);
        textSize(16);
        text(hitsRemaining, x + w/2, y + h/2);
      }
    } else if (dying) {
      float t = deathTimer / DEATH_FRAMES;
      float s = 0.3 + 0.7 * t;
      pushMatrix();
      translate(x + w/2, y + h/2);
      scale(s);
      tint(255, 255 * t * t);
      imageMode(CENTER);
      image(sprite, 0, 0, w, h);
      imageMode(CORNER);
      noTint();
      popMatrix();
    }
  }
}
