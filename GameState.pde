// Per-state handlers for the game's state machine. Replaces the duplicated
// if/else chains that used to live in draw() and mousePressed(): adding a new
// state now means adding a subclass + one array slot (see setup()), touching
// nothing else. `int state` stays the single source of truth; every existing
// `state = STATE_X` transition is left untouched.
//
// These are non-static inner classes, so they can read the sketch globals
// (score, ball, paddle, bricks, effects, ...) and call the top-level helpers
// (drawBricks(), updatePlaying(), drawCenteredScreen(), resetGame(), ...).
abstract class GameState {
  void draw() {}
  void onClick() {}
}

class StartState extends GameState {
  void draw() {
    drawBricks();
    paddle.display();
    ball.display();
    drawCenteredScreen("BRICK BREAKER", "Click to start   -   Mouse or Arrow Keys to move");
  }
  void onClick() {
    state = STATE_PLAYING;
  }
}

class PlayingState extends GameState {
  void draw() {
    updatePlaying();

    pushMatrix();
    effects.applyShake();
    drawBricks();
    updateBricks();
    paddle.display();
    ball.display();
    effects.updateAndDraw();
    popMatrix();

    drawHUD();
  }
}

class WinningState extends GameState {
  void draw() {
    // Freeze the ball but keep the last brick's fade and the burst playing out.
    drawBricks();
    updateBricks();
    paddle.display();
    ball.display();
    effects.updateAndDraw();
    drawHUD();

    winTimer--;
    if (winTimer <= 0) state = STATE_WIN;
  }
}

class GameOverState extends GameState {
  void draw() {
    drawBricks();
    drawCenteredScreen("GAME OVER", "Score: " + score + "   -   Click to restart");
  }
  void onClick() {
    resetGame();
    state = STATE_PLAYING;
  }
}

class WinState extends GameState {
  void draw() {
    drawCenteredScreen("YOU WIN!", "Score: " + score + "   -   Click to restart");
  }
  void onClick() {
    resetGame();
    state = STATE_PLAYING;
  }
}
