// RenderManager.pde

void renderWorld() {
  imageMode(CORNER);
  image(getLevelBG(), 0, 0, width, height);  // draw current background
  
  if (showTitle) {
    drawTitle();
    if (millis() - titleStart > TITLE_TIME) {
      showTitle = false;
    }
    return;
  }
  
  if (state == GameState.END) {
    drawEndSlide();
    return;
  }
  
  if (state == GameState.LOSE) {
    drawLoseSlide();
    return;
  }
  
  // Draw hotspots and enemies
  for (Hotspot h : hotspots) h.draw();
  for (Enemy d : demons) d.draw();
  
  // Draw main player
  imageMode(CENTER);
  if (imgPlayer != null) {
    image(imgPlayer, playerPos.x, playerPos.y, PLAYER_SIZE, PLAYER_SIZE);
  } else {
    fill(0, 255, 0);
    ellipse(playerPos.x, playerPos.y, PLAYER_SIZE, PLAYER_SIZE);
  }
  
  // Draw current weapon image next to player during SWEEP and FIGHT phases
  if (state == GameState.SWEEP || state == GameState.FIGHT) {
    if (weaponImg != null) {
      imageMode(CENTER);
      // Position the weapon to the right of the player
      image(weaponImg, playerPos.x + PLAYER_SIZE/2 + 20, playerPos.y, PLAYER_SIZE/2, PLAYER_SIZE/2);
    }
  }
  
  // Heads up display
  fill(255);
  textSize(16);
  textAlign(LEFT);
  text("State: " + state, 10, 20);
  float health = max(0, 50 - glitchLevel);  // Health calculated from glitchLevel
  text("Health: " + nf(health, 1, 2), 10, 40);
  text("Level: " + levelNames[levelIdx], 10, 60);
  if (state == GameState.ASCEND) {  // prompt to ascend
    text("Press [E] to Ascend", CANVAS_W/2 - 70, CANVAS_H - 30);
  }
}

void drawIntro() {
  imageMode(CORNER);
  image(bgIntro, 0, 0, width, height);
  
  fill(255);
  text("Welcome to Signal Lost", width/2, height/2 - 40);
  text("A Collage Surrealist Horror", width/2, height/2);
  text("Press any key to begin…", width/2, height/2 + 40);
  
  // End intro after TITLE_TIME if any key is pressed
  if (millis() - introStart > TITLE_TIME && keyPressed) {
    showIntro = false;
  }
}

void drawTransit() {
  imageMode(CORNER);
  image(bgStairs, 0, 0, width, height);
  
  // Show weapon discovery message during transit if applicable
  if (levelIdx == 1 || levelIdx == 2) {
    fill(255);
    textSize(22);
    textAlign(CENTER, CENTER);
    text("New Weapon Discovered: " + weaponName, width/2, height - 50);
  }
  
  if (millis() - transitStart > TRANSIT_TIME) {
    inTransit = false;
    initLevel();
  }
}

void drawTitle() {
  imageMode(CORNER);
  image(getLevelBG(), 0, 0, width, height);
  fill(255);
  textSize(48);
  text(levelNames[levelIdx], width/2, height/2);
}

void drawEndSlide() {
  background(0);
  fill(255);
  textSize(22);
  textAlign(CENTER, CENTER);
  text("Congrats, you cleared the glitch demons and fixed the antenna, closing the glitch void", width/2, height/2);
}

void drawLoseSlide() {
  background(0);
  fill(255);
  textSize(22);
  textAlign(CENTER, CENTER);
  text("You Lost! The glitch void consumed the signal.", width/2, height/2);
}
