class Paddle {
  float x, y;
  float w, h;
  PImage sprite;

  Paddle(float startX, float startY, float pw, float ph, PImage img) {
    x = startX;
    y = startY;
    w = pw;
    h = ph;
    sprite = img;
  }

  void update() {
    x = mouseX - w / 2;
    x = constrain(x, 0, width - w);
  }

  void display() {
    imageMode(CENTER);
    image(sprite, x + w / 2, y + h / 2, w, h);
    imageMode(CORNER);
  }
}
