// Simple sound manager using Processing's Sound library.
// Plays short beeps for game events.

import processing.sound.*;

SoundManager soundManager;

class SoundManager {
  AudioDevice device;
  SinOsc osc;
  float freq = 0;
  float duration = 0.1;   // seconds
  float amp = 0.3;
  boolean isPlaying = false;
  float startTime = 0;
  
  SoundManager(PApplet parent) {
    device = new AudioDevice(parent, 44100, 16);
    osc = new SinOsc(parent);
    osc.amp(amp);
  }
  
  // Play a tone at given frequency for given duration (in seconds)
  void playTone(float frequency, float dur) {
    freq = frequency;
    duration = dur;
    osc.freq(freq);
    osc.play();
    startTime = millis() / 1000.0;
    isPlaying = true;
  }
  
  // Call this every frame to stop the tone after duration
  void update() {
    if (isPlaying) {
      float now = millis() / 1000.0;
      if (now - startTime >= duration) {
        osc.stop();
        isPlaying = false;
      }
    }
  }
  
  // Convenience methods
  void paddleHit()  { playTone(600, 0.08); }
  void brickHit()   { playTone(900, 0.06); }
  void wallBounce() { playTone(400, 0.05); }
  void lifeLost()   { playTone(200, 0.3); }
  void levelUp()    { playTone(1200, 0.15); playTone(1500, 0.15); } // two beeps
  void powerUp()    { playTone(800, 0.1); playTone(1000, 0.1); }
  void gameOver()   { playTone(100, 0.5); playTone(80, 0.5); }
  void win()        { playTone(600, 0.15); playTone(800, 0.15); playTone(1000, 0.15); }
}
