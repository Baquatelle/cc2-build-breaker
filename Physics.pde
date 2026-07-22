// Collision orchestration: detects overlaps and applies the *physical* response
// (ball reflection / repositioning). Deliberately owns no game rules — scoring,
// particle bursts, win detection, and life loss stay in the game layer, which
// reacts to what these methods report. That split keeps physics reusable and
// free of score/state/effects coupling.
class Physics {

  // Reflect the ball off the paddle when they overlap while descending.
  // Returns true if a deflection happened, so the caller can react (e.g. squash).
  boolean resolvePaddle(Ball ball, Paddle paddle) {
    if (ball.hitsPaddle(paddle)) {
      ball.deflectOffPaddle(paddle);
      return true;
    }
    return false;
  }

  // Find the first brick the ball hits (one per frame), bounce the ball off it,
  // and return that brick so the caller can apply consequences (score, burst,
  // win check). Returns null when nothing was hit.
  Brick resolveBricks(Ball ball, Brick[][] bricks) {
    for (int row = 0; row < bricks.length; row++) {
      for (int col = 0; col < bricks[row].length; col++) {
        Brick b = bricks[row][col];
        if (b.collides(ball.x, ball.y, ball.r)) {
          ball.bounceOffBrick(b);
          return b;
        }
      }
    }
    return null;
  }
}
