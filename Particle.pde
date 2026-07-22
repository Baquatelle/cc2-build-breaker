// A tiny, short-lived particle used for the brick-destruction burst.
class Particle {
  float x, y;
  float vx, vy;
  float life;        // remaining life, 1.0 -> 0.0
  float decay;       // life lost per frame
  float size;
  color col;

  Particle(float px, float py, color c) {
    x = px;
    y = py;
    float angle = random(TWO_PI);
    float speed = random(1.5, 5.0);
    vx = cos(angle) * speed;
    vy = sin(angle) * speed;
    life = 1.0;
    decay = random(0.02, 0.05);
    size = random(3, 7);
    col = c;
  }

  void update() {
    x += vx;
    y += vy;
    vy += 0.12;      // a little gravity
    vx *= 0.98;      // drag
    vy *= 0.98;
    life -= decay;
  }

  boolean isDead() {
    return life <= 0;
  }

  void display() {
    noStroke();
    fill(red(col), green(col), blue(col), 255 * constrain(life, 0, 1));
    float s = size * life;
    ellipse(x, y, s, s);
  }
}
