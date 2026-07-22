class Paddle {
  float x, y;
  float w, h;
  float speed = 7;
  PImage sprite;

  // Brief squash animation when the paddle deflects the ball.
  int squashTimer = 0;
  final int SQUASH_FRAMES = 8;

  Paddle(float startX, float startY, float pw, float ph, PImage img) {
    x = startX;
    y = startY;
    w = pw;
    h = ph;
    sprite = img;
  }

  void update() {
    if (keyPressed && (keyCode == LEFT || keyCode == RIGHT)) {
      if (keyCode == LEFT) x -= speed;
      if (keyCode == RIGHT) x += speed;
    } else {
      x = mouseX - w / 2;
    }
    x = constrain(x, 0, width - w);

    if (squashTimer > 0) squashTimer--;
  }

  void squash() {
    squashTimer = SQUASH_FRAMES;
  }

  void display() {
    // Squash factor eases from full effect back to 1.0 over the timer.
    float t = squashTimer / (float) SQUASH_FRAMES;
    float sx = 1.0 + 0.25 * t;   // widen briefly
    float sy = 1.0 - 0.35 * t;   // flatten briefly

    pushMatrix();
    translate(x + w / 2, y + h / 2);
    scale(sx, sy);
    imageMode(CENTER);
    image(sprite, 0, 0, w, h);
    imageMode(CORNER);
    popMatrix();
  }
}
