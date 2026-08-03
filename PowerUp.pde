// Power-up drops from bricks, falls, and gives temporary bonuses when caught.
class PowerUp {
  float x, y;
  int type;
  float speed = 2.5;
  float size = 20;
  boolean active = true;

  // Type constants – use these in the main sketch.
  static final int WIDER = 0;
  static final int EXTRA_LIFE = 1;
  static final int SLOW_BALL = 2;
  static final int MULTI_BALL = 3;

  PowerUp(float x, float y, int type) {
    this.x = x;
    this.y = y;
    this.type = type;
  }

  void update() {
    y += speed;
    if (y > height + 30) active = false;
  }

  // Check if this power-up has hit the paddle.
  boolean hitsPaddle(Paddle p) {
    float half = size/2;
    return x + half > p.x && x - half < p.x + p.w &&
           y + half > p.y && y - half < p.y + p.h;
  }

  void display() {
    pushMatrix();
    translate(x, y);
    // Color by type
    switch(type) {
      case WIDER:      fill(0, 200, 255); break;
      case EXTRA_LIFE: fill(0, 255, 100); break;
      case SLOW_BALL:  fill(255, 200, 0); break;
      case MULTI_BALL: fill(255, 50, 150); break;
    }
    noStroke();
    ellipse(0, 0, size, size);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(12);
    switch(type) {
      case WIDER:      text("W", 0, 2); break;
      case EXTRA_LIFE: text("+", 0, 2); break;
      case SLOW_BALL:  text("S", 0, 2); break;
      case MULTI_BALL: text("M", 0, 2); break;
    }
    popMatrix();
  }
}
