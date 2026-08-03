// Per-state handlers for the game's state machine. Replaces the duplicated
// if/else chains that used to live in draw() and mousePressed(): adding a new
// state now means adding a subclass + one array slot (see setup()), touching
// nothing else. `int state` stays the single source of truth; every existing
// `state = STATE_X` transition is left untouched.
//
// These are non-static inner classes, so they can read the sketch globals
// (score, balls, paddle, bricks, effects, ...) and call the top-level helpers
// (drawBricks(), updatePlaying(), drawCenteredScreen(), resetGame(), ...).

abstract class GameState {
  void draw() {}
  void onClick() {}
  void keyPressed() {}   // needed for high-score input
}

class StartState extends GameState {
  void draw() {
    drawBricks();
    paddle.display();
    if (!balls.isEmpty()) balls.get(0).display();
    drawCenteredScreen("BRICK BREAKER", "Click to start   -   Mouse or Arrow Keys to move");
    drawHighScores(20, height - 100);
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
    for (Ball b : balls) b.display();

    for (PowerUp p : powerups) p.display();

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
    for (Ball b : balls) b.display();
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
    drawHighScores(20, height - 100);
  }
  void onClick() {
    resetGame();
    state = STATE_START;
  }
}

class WinState extends GameState {
  void draw() {
    drawCenteredScreen("YOU WIN!", "Score: " + score + "   -   Click to restart");
    drawHighScores(20, height - 100);
  }
  void onClick() {
    resetGame();
    state = STATE_START;
  }
}

class EnterHighScoreState extends GameState {
  void draw() {
    fill(0, 180);
    rect(0, 0, width, height);
    fill(255);
    textAlign(CENTER, CENTER);
    textSize(32);
    text("New High Score!", width/2, height/2 - 60);
    textSize(24);
    text("Enter your initials (3 letters):", width/2, height/2 - 20);
    textSize(36);
    text(newHighScoreName + "_", width/2, height/2 + 30);
    textSize(16);
    text("Press ENTER to save", width/2, height/2 + 80);
  }
  
  void keyPressed() {
    if (key == ENTER || key == RETURN) {
      if (newHighScoreName.length() > 0) {
        String initials = newHighScoreName.toUpperCase();
        while (initials.length() < 3) initials += " ";
        addHighScore(initials, tempScore);
        resetGame();
        state = STATE_START;
      }
    } else if (key == BACKSPACE) {
      if (newHighScoreName.length() > 0) {
        newHighScoreName = newHighScoreName.substring(0, newHighScoreName.length()-1);
      }
    } else if (key >= 'A' && key <= 'Z' || key >= 'a' && key <= 'z') {
      if (newHighScoreName.length() < 3) {
        newHighScoreName += char(key);
      }
    }
  }
  
  void onClick() {
    // Treat click as ENTER (submit)
    if (newHighScoreName.length() > 0) {
      String initials = newHighScoreName.toUpperCase();
      while (initials.length() < 3) initials += " ";
      addHighScore(initials, tempScore);
      resetGame();
      state = STATE_START;
    }
  }
}
