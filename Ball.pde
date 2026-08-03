class Ball {
  float x, y;
  float prevX, prevY;
  float vx, vy;
  float r;
  float angle = 0;
  PImage sprite;
  boolean isMain = false;

  // Trail
  ArrayList<PVector> trailPos;
  ArrayList<Float> trailAngles;
  int TRAIL_LENGTH = 20;


  Ball(float startX, float startY, float radius, PImage img) {
    this(startX, startY, radius, img, true);
  }

  Ball(float startX, float startY, float radius, PImage img, boolean main) {
    x = startX;
    y = startY;
    r = radius;
    sprite = img;
    isMain = main;
    trailPos = new ArrayList<PVector>();
    trailAngles = new ArrayList<Float>();
  }

  void launch() {
    float dir = random(1) < 0.5 ? -1 : 1;
    vx = 3 * dir;
    vy = -4;
    trailPos.clear();
    trailAngles.clear();
  }

  void update() {
    prevX = x;
    prevY = y;

    x += vx;
    y += vy;

    if (x - r < 0) {
      x = r;
      vx = -vx;
      sound.wallBounce();
    } else if (x + r > width) {
      x = width - r;
      vx = -vx;
      sound.wallBounce();
    }
    if (y - r < 0) {
      y = r;
      vy = -vy;
      sound.wallBounce();
    }

    angle += vx * 0.05;

    // Record trail
    trailPos.add(new PVector(x, y));
    trailAngles.add(angle);
    if (trailPos.size() > TRAIL_LENGTH) {
      trailPos.remove(0);
      trailAngles.remove(0);
    }
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
    // Trail ghosts – guard against size 1 to avoid NaN
    if (trailPos.size() > 1) {
      for (int i = 0; i < trailPos.size(); i++) {
        PVector p = trailPos.get(i);
        float a = trailAngles.get(i);
        float alpha = map(i, 0, trailPos.size()-1, 20, 150);
        float s = map(i, 0, trailPos.size()-1, 0.3, 0.9);
        pushMatrix();
        translate(p.x, p.y);
        rotate(a);
        scale(s);
        tint(255, alpha);
        image(sprite, -r, -r, r*2, r*2);
        noTint();
        popMatrix();
      }
    }
  
    // Main ball
    pushMatrix();
    translate(x, y);
    rotate(angle);
    imageMode(CENTER);
    image(sprite, 0, 0, r * 2, r * 2);
    imageMode(CORNER);
    popMatrix();
  }
}
