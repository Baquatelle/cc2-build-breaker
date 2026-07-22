class Paddle {
  float x, y;
  float w, h;
  float speed = 7;
  PImage sprite;

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
  }

  void display() {
    imageMode(CENTER);
    image(sprite, x + w / 2, y + h / 2, w, h);
    imageMode(CORNER);
  }
}
