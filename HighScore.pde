import java.util.Collections;

class HighScore implements Comparable<HighScore> {
  String name;
  int score;
  
  HighScore(String name, int score) {
    this.name = name;
    this.score = score;
  }
  
  int compareTo(HighScore other) {
    return other.score - this.score; // descending
  }
}

ArrayList<HighScore> highScores = new ArrayList<HighScore>();

void loadHighScores() {
  String[] lines = loadStrings("scores.txt");
  if (lines != null) {
    for (String line : lines) {
      String[] parts = split(line, ',');
      if (parts.length == 2) {
        highScores.add(new HighScore(parts[0], int(parts[1])));
      }
    }
    Collections.sort(highScores);
    // Trim to top 5
    while (highScores.size() > 5) {
      highScores.remove(highScores.size()-1);
    }
  }
}

void saveHighScores() {
  String[] lines = new String[min(highScores.size(), 5)];
  for (int i = 0; i < lines.length; i++) {
    lines[i] = highScores.get(i).name + "," + highScores.get(i).score;
  }
  saveStrings("scores.txt", lines);
}

void addHighScore(String name, int score) {
  highScores.add(new HighScore(name, score));
  Collections.sort(highScores);
  while (highScores.size() > 5) {
    highScores.remove(highScores.size()-1);
  }
  saveHighScores();
}

boolean isHighScore(int score) {
  // If less than 5 scores, any positive score qualifies
  if (highScores.size() < 5) return score > 0;
  return score > highScores.get(highScores.size()-1).score;
}

void drawHighScores(float x, float y) {
  fill(255);
  textAlign(LEFT, TOP);
  textSize(18);
  text("High Scores", x, y);
  textSize(14);
  for (int i = 0; i < min(highScores.size(), 5); i++) {
    HighScore hs = highScores.get(i);
    text((i+1) + ". " + hs.name + "  " + hs.score, x, y + 25 + i*20);
  }
}
