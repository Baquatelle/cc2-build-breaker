class Ball {
  float x, y;
  float prevX, prevY;
  float vx, vy;
  float r;
  float angle = 0;
  PImage sprite;

  Ball(float startX, float startY, float radius, PImage img) {
    x = startX;
    y = startY;
    r = radius;
    sprite = img;
  }

  void launch() {
    float dir = random(1) < 0.5 ? -1 : 1;
    vx = 3 * dir;
    vy = -4;
  }

  void update() {
    prevX = x;
    prevY = y;

    x += vx;
    y += vy;

    if (x - r < 0) {
      x = r;
      vx = -vx;
    } else if (x + r > width) {
      x = width - r;
      vx = -vx;
    }
    if (y - r < 0) {
      y = r;
      vy = -vy;
    }

    angle += vx * 0.05;
  }

  boolean isBelowScreen() {
    return y - r > height;
  }

  // --- Bounce behavior (owns paddle/brick reflection per REQUIREMENTS) ---

  void bounceX() {
    vx = -vx;
  }

  void bounceY() {
    vy = -vy;
  }

  // Deflect off the paddle: reposition to rest on top, then steer the outgoing
  // angle by where the ball struck relative to the paddle center (classic
  // Breakout feel), preserving overall speed.
  void deflectOffPaddle(Paddle p) {
    y = p.y - r;
    float relativeIntersect = (x - (p.x + p.w / 2)) / (p.w / 2);
    relativeIntersect = constrain(relativeIntersect, -1, 1);
    float speed = sqrt(vx * vx + vy * vy);
    vx = relativeIntersect * speed;
    vy = -sqrt(max(speed * speed - vx * vx, speed * speed * 0.3));
  }

  // True when the ball overlaps the paddle's rect while moving downward.
  boolean hitsPaddle(Paddle p) {
    return vy > 0
        && x + r > p.x && x - r < p.x + p.w
        && y + r > p.y && y - r < p.y + p.h;
  }

  // Reflect off a brick based on the approach direction (using prev position).
  void bounceOffBrick(Brick b) {
    boolean wasAboveOrBelow = (prevY + r <= b.y) || (prevY - r >= b.y + b.h);
    boolean wasLeftOrRight = (prevX + r <= b.x) || (prevX - r >= b.x + b.w);
    if (wasAboveOrBelow) {
      bounceY();
    } else if (wasLeftOrRight) {
      bounceX();
    } else {
      bounceY();
    }
  }

  void display() {
    pushMatrix();
    translate(x, y);
    rotate(angle);
    imageMode(CENTER);
    image(sprite, 0, 0, r * 2, r * 2);
    imageMode(CORNER);
    popMatrix();
  }
}
