// Owns the "juice": brick-destruction particle bursts and screen shake.
// Extracted from the main tab so effects state and lifecycle live in one place.
class Effects {
  ArrayList<Particle> particles = new ArrayList<Particle>();

  float shakeTimer = 0;
  final float SHAKE_DURATION = 12;
  final float SHAKE_MAG = 6;

  // Spawn a burst of particles at (cx, cy) in the given color and kick the shake.
  void burst(float cx, float cy, color c) {
    int count = (int) random(10, 16);
    for (int i = 0; i < count; i++) {
      particles.add(new Particle(cx, cy, c));
    }
    shakeTimer = SHAKE_DURATION;
  }

  // Apply the current screen shake as a translate(). Call inside push/popMatrix.
  // Advances the shake clock as a side effect of being applied this frame.
  void applyShake() {
    if (shakeTimer > 0) {
      float mag = SHAKE_MAG * (shakeTimer / SHAKE_DURATION);
      translate(random(-mag, mag), random(-mag, mag));
      shakeTimer--;
    }
  }

  // Advance and draw all live particles, reaping dead ones.
  void updateAndDraw() {
    for (int i = particles.size() - 1; i >= 0; i--) {
      Particle p = particles.get(i);
      p.update();
      p.display();
      if (p.isDead()) particles.remove(i);
    }
  }

  void clear() {
    particles.clear();
    shakeTimer = 0;
  }
}
