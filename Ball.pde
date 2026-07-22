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
