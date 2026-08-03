// Maps game events to sounds. Every clip is synthesized once here at startup,
// so playing one during the game is just a queue push (see Tone.pde).
//
// Multi-note events render as a single clip, which is why their notes actually
// sound in sequence. The previous oscillator-based version restarted one shared
// oscillator per note, so only the last note of a sequence was ever audible.

class SoundManager {
  Tone tone;

  byte[] paddleHitClip;
  byte[] brickHitClip;
  byte[] wallBounceClip;
  byte[] lifeLostClip;
  byte[] levelUpClip;
  byte[] powerUpClip;
  byte[] gameOverClip;
  byte[] winClip;

  SoundManager() {
    tone = new Tone();

    paddleHitClip   = tone.render(new float[] { 600 }, 0.08);
    brickHitClip    = tone.render(new float[] { 900 }, 0.06);
    wallBounceClip  = tone.render(new float[] { 400 }, 0.05);
    lifeLostClip    = tone.render(new float[] { 200 }, 0.3);
    levelUpClip     = tone.render(new float[] { 1200, 1500 }, 0.15);
    powerUpClip     = tone.render(new float[] { 800, 1000 }, 0.1);
    gameOverClip    = tone.render(new float[] { 100, 80 }, 0.5);
    winClip         = tone.render(new float[] { 600, 800, 1000 }, 0.15);
  }

  void paddleHit()  { tone.play(paddleHitClip); }
  void brickHit()   { tone.play(brickHitClip); }
  void wallBounce() { tone.play(wallBounceClip); }
  void lifeLost()   { tone.play(lifeLostClip); }
  void levelUp()    { tone.play(levelUpClip); }
  void powerUp()    { tone.play(powerUpClip); }
  void gameOver()   { tone.play(gameOverClip); }
  void win()        { tone.play(winClip); }
}
