// Per-state handlers for the game's state machine.
// Each state implements draw(), onClick(), and optionally keyPressed().
abstract class GameState {
  void draw() {}
  void onClick() {}
  void keyPressed() {}   // needed for high-score input
}

class StartState extends GameState {
  void draw() {
    drawBricks();
    paddle.display();
    ball.display();
    drawCenteredScreen("BRICK BREAKER", "Click to start   -   Mouse or Arrow Keys to move");
    drawHighScores(20, height - 120);   // show high scores
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

    // Draw power‑ups and multi‑balls
    for (PowerUp p : powerups) p.display();
    for (Ball mb : multiBalls) mb.display();

    effects.updateAndDraw();
    popMatrix();

    drawHUD();
  }
}

class WinningState extends GameState {
  void draw() {
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
    drawHighScores(20, height - 120);
  }
  void onClick() {
    resetGame();
    state = STATE_START;
  }
}

class WinState extends GameState {
  void draw() {
    drawCenteredScreen("YOU WIN!", "Score: " + score + "   -   Click to restart");
    drawHighScores(20, height - 120);
  }
  void onClick() {
    resetGame();
    state = STATE_START;
  }
}

// ########## HIGH SCORE INPUT STATE ##########
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
        while (newHighScoreName.length() < 3) newHighScoreName += " ";
        addHighScore(newHighScoreName, tempScore);
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
}
