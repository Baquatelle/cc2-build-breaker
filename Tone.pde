// Zero-dependency tone synthesizer, built on the JDK's own javax.sound.sampled
// (part of the same java.desktop module Processing already relies on for its
// window), so the sketch needs no contributed libraries; see REQUIREMENTS.md.
//
// Sounds are synthesized to raw PCM once up front (see SoundManager) and handed
// to a single daemon thread that owns the audio line. Triggering a sound from
// draw() is therefore just a queue push: no allocation, no blocking, and no
// per-frame bookkeeping. Rendered clips are never mutated, so the same array
// can be queued again while an earlier play of it is still sounding.

import javax.sound.sampled.AudioFormat;
import javax.sound.sampled.AudioSystem;
import javax.sound.sampled.SourceDataLine;
import java.util.concurrent.ArrayBlockingQueue;

class Tone {
  final float SAMPLE_RATE = 44100;
  final float AMPLITUDE = 0.3;            // headroom, so notes never clip
  final float ATTACK_SECONDS = 0.004;     // brief ramp-in; kills the click on note onset

  // Caps playback latency at about 46ms, which is what 4096 bytes comes to in
  // this format. That is a ceiling rather than the usual case: the line sits
  // idle between sparse beeps, so a fresh write is normally audible sooner.
  // Raise it if you hear crackle on slower hardware.
  final int LINE_BUFFER_BYTES = 4096;

  // Room for one waiting clip: take() frees the slot before the worker
  // blocks in write(), so one beep can queue while another sounds. Not a
  // mixer, though: playback is sequential, so whatever waits sounds after
  // the current clip, not alongside it. Holding one bounds how late a beep
  // can be by the length of the clip already playing, and drops anything
  // behind that rather than letting it pile up.
  final int QUEUE_CAPACITY = 1;

  // Consecutive failed writes that make the playback thread give up rather
  // than reopen the device again. Every failure below this one still gets a
  // reopen, since a lone glitch is usually a transient output switch; a steady
  // stream means the line is gone for good, and retrying forever would churn
  // the device open and closed behind every beep with nothing to show for it.
  final int MAX_WRITE_FAILURES = 3;

  final ArrayBlockingQueue<byte[]> pending = new ArrayBlockingQueue<byte[]>(QUEUE_CAPACITY);

  // Reassigned by the playback thread when it recovers from, or gives up on, a
  // dead device while play() reads it on the main thread, so it has to be
  // volatile. A null line is how "no audio" is recorded: play() then does
  // nothing, which is also the only state play() ever inspects.
  volatile SourceDataLine line;

  Tone() {
    if (openLine()) startPlaybackThread();
  }

  // Claim the default output line. Doubles as the mid-game recovery path, so it
  // releases whatever line it replaces and publishes only a fully opened one:
  // a half-opened line left in the field would collect beeps that never sound.
  boolean openLine() {
    // Retire the old line before reaching for a new one, so that a failed close
    // cannot be mistaken for a failed reopen: the try below then carries only
    // the one meaning, "could not open".
    retire(line);

    AudioFormat format = new AudioFormat(SAMPLE_RATE, 16, 1, true, false);
    try {
      SourceDataLine opened = AudioSystem.getSourceDataLine(format);
      opened.open(format, LINE_BUFFER_BYTES);
      opened.start();
      line = opened;
      return true;
    } catch (Exception e) {
      // No usable device: headless, already claimed or an unsupported format at
      // startup, or the device went away mid-game. Run silent instead of taking
      // the game down.
      println("Tone: audio unavailable, continuing without sound (" + e + ")");
      return false;
    }
  }

  // Fall silent and hand the device back. Clearing the field first makes the
  // gap explicitly silent, since that null is what play() checks. Takes the
  // line to release as an argument rather than reading the field, so the
  // give-up path closes the exact line whose write failed.
  // Closing is best-effort: a close that fails is ignored.
  void retire(SourceDataLine dead) {
    line = null;
    if (dead == null) return;
    try {
      dead.close();
    } catch (Exception e) {
      // A device that has already vanished routinely throws on close. That
      // tells us nothing we can act on, and must not abort a reopen that
      // follows.
    }
  }

  // Synthesize a run of equal-length sine notes as little-endian 16-bit mono PCM.
  // Each note carries its own envelope, so a sequence articulates as distinct
  // beeps and every note both starts and ends at silence.
  byte[] render(float[] freqs, float noteSeconds) {
    int samplesPerNote = (int) (SAMPLE_RATE * noteSeconds);
    // Integer math throughout: PApplet offers min(int, int) and min(float, float)
    // but nothing mixed, so staying in one type keeps overload resolution simple.
    int attack = max(1, min((int) (ATTACK_SECONDS * SAMPLE_RATE), samplesPerNote / 4));

    byte[] pcm = new byte[freqs.length * samplesPerNote * 2];
    int pos = 0;
    for (int n = 0; n < freqs.length; n++) {
      for (int i = 0; i < samplesPerNote; i++) {
        float envelope = (i < attack)
          ? i / (float) attack
          : 1 - (i - attack) / (float) (samplesPerNote - attack);
        float sample = sin(TWO_PI * freqs[n] * i / SAMPLE_RATE) * AMPLITUDE * envelope;
        short value = (short) (sample * Short.MAX_VALUE);
        pcm[pos++] = (byte) (value & 0xFF);
        pcm[pos++] = (byte) ((value >> 8) & 0xFF);
      }
    }
    return pcm;
  }

  // Queue an already-rendered sound. Safe to call from draw(): it never blocks,
  // never allocates, and does nothing when audio is unavailable.
  void play(byte[] pcm) {
    if (line != null) pending.offer(pcm);
  }

  // One thread owns the audio line, replacing it if the device fails under it.
  // write() returns only as the hardware takes the samples, which paces
  // playback for free.
  void startPlaybackThread() {
    Thread player = new Thread(new Runnable() {
      public void run() {
        int failures = 0;   // consecutive; only this thread touches it
        try {
          while (true) {
            byte[] pcm = pending.take();
            // One read of the volatile, so this write stays pinned to a single
            // line even though the recovery path below replaces it. No null
            // check belongs here: the thread starts with a line open, only this
            // thread writes the field afterwards, and every path that clears it
            // either restores a line before looping back or leaves the loop.
            SourceDataLine current = line;
            // Only the write is guarded. Unplugging the output device kills the
            // line mid-game, and letting that escape would end this thread and
            // with it every later sound. take() stays outside, so an interrupt
            // ends the thread instead of being charged to the failure budget.
            try {
              current.write(pcm, 0, pcm.length);
              failures = 0;            // wrote cleanly: past trouble was transient
            } catch (Exception e) {
              if (++failures >= MAX_WRITE_FAILURES) {
                // Reopening keeps succeeding while writing never does. Mute
                // exactly the way a failed reopen would, so play() goes quiet
                // too, and release the line we actually failed on.
                retire(current);
                println("Tone: audio device kept failing, continuing without sound (" + e + ")");
                return;
              }
              // openLine() retires this dead line before claiming a new one.
              if (!openLine()) return;   // gave up: play() is a no-op from here
            }
          }
        } catch (InterruptedException e) {
          // take() declares this, so the catch has to exist, but nothing in the
          // sketch interrupts this thread. The daemon flag below is what ends
          // it, and JVM exit hands the output device back, so there is nothing
          // to release here.
        }
      }
    });
    player.setDaemon(true);   // must never outlive the sketch window
    player.start();
  }
}
