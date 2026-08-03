// Simple sound manager using Processing's Sound library.
// Plays short beeps for game events.

import processing.sound.*;

class SoundManager {
  AudioDevice device;
  SinOsc osc;
  boolean isPlaying = false;
  float startTime = 0;
  float duration = 0.1;
  
  // Queue of tones to play sequentially
  ArrayList<Float> toneQueue = new ArrayList<Float>();
  ArrayList<Float> durQueue = new ArrayList<Float>();

  SoundManager(PApplet parent) {
    // Use default device with reasonable buffer size
    device = new AudioDevice(parent, 44100, 512);
    osc = new SinOsc(parent);
    osc.amp(0.3);
  }
  
  void playTone(float frequency, float dur) {
    // Add to queue
    toneQueue.add(frequency);
    durQueue.add(dur);
    if (!isPlaying) {
      // Start immediately if not already playing
      playNext();
    }
  }
  
  void playNext() {
    if (toneQueue.isEmpty()) {
      isPlaying = false;
      osc.stop();
      return;
    }
    isPlaying = true;
    float freq = toneQueue.remove(0);
    float dur = durQueue.remove(0);
    osc.freq(freq);
    osc.play();
    startTime = millis() / 1000.0;
    duration = dur;
  }
  
  void update() {
    if (isPlaying) {
      float now = millis() / 1000.0;
      if (now - startTime >= duration) {
        osc.stop();
        // Play next tone in queue
        playNext();
      }
    } else {
      // If no tone playing and queue not empty, start next
      if (!toneQueue.isEmpty()) {
        playNext();
      }
    }
  }
  
  // Convenience methods
  void paddleHit()  { playTone(600, 0.08); }
  void brickHit()   { playTone(900, 0.06); }
  void wallBounce() { playTone(400, 0.05); }
  void lifeLost()   { playTone(200, 0.3); }
  void levelUp()    { playTone(1200, 0.15); playTone(1500, 0.15); }
  void powerUp()    { playTone(800, 0.1); playTone(1000, 0.1); }
  void gameOver()   { playTone(100, 0.5); playTone(80, 0.5); }
  void win()        { playTone(600, 0.15); playTone(800, 0.15); playTone(1000, 0.15); }
}
