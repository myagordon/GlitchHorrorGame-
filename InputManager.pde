// Handles keyboard and mouse input
void handleInput() {
  // Adjust direction vector based on WASD keys
  PVector dir = new PVector();
  if (keyPressed) {
    if (key == 'w' || key == 'W') dir.y--;
    if (key == 's' || key == 'S') dir.y++;
    if (key == 'a' || key == 'A') dir.x--;
    if (key == 'd' || key == 'D') dir.x++;
  }
  if (dir.mag() > 0) {
    dir.normalize().mult(3);  // scale the speed
    playerPos.add(dir);
    playerPos.x = constrain(playerPos.x, 0, CANVAS_W);
    playerPos.y = constrain(playerPos.y, 0, CANVAS_H);
  }
  
  // Shooting (simulate a shot when mouse is pressed)
  if (mousePressed) {
    // Define hit threshold depending on the weapon
    float precisionThreshold = DEMON_SIZE * 0.5;  // default for first weapon
    if (levelIdx == 1) {
      precisionThreshold = DEMON_SIZE * 0.7;  // Radiowave Tazer
    } else if (levelIdx == 2) {
      precisionThreshold = DEMON_SIZE * 0.9;  // LRAD
    }
    for (int i = demons.size() - 1; i >= 0; i--) {
      Enemy d = demons.get(i);
      if (dist(mouseX, mouseY, d.pos.x, d.pos.y) < precisionThreshold) {
        d.hp--;
        sendOSC("/damageFlash", 1);
        if (d.hp <= 0) {
          demons.remove(i);
        }
      }
    }
  }
  
  // Ascend to the next level if state is ASCEND and E is pressed
  if (state == GameState.ASCEND && keyPressed && (key == 'e' || key == 'E')) {
    if (!inTransit) {  // wait until transit is complete
      if (levelIdx < levelNames.length - 1) {
        levelIdx = min(levelIdx + 1, levelNames.length - 1);
        inTransit = true;
        transitStart = millis();
      } else {
        // Last level reached; game ends in win state
        state = GameState.END;
        glitchLevel = 0;  // Reset for end screen
      }
    }
  }
}
