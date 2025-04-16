// UpdateWorld.pde

void updateWorld(float dt) {
  switch (state) {
    case SWEEP:
      // If the player enters an uncleared hotspot, spawn a new enemy wave
      for (Hotspot h : hotspots) {
        if (!h.cleared && PVector.dist(playerPos, h.pos) < 40) {
          h.cleared = true;
          spawnWave();
          state = GameState.FIGHT;
          sendOSC("/phase", 1);
        }
      }
      break;
    case FIGHT:
      // Have each enemy act; if an enemy is too close, increase glitch level
      for (Enemy d : demons) {
        d.act(playerPos, dt);
        if (PVector.dist(d.pos, playerPos) < 50) {
          glitchLevel += 0.25 * dt;
        }
      }
      // Once all demons are defeated, move to the ASCEND state
      if (demons.isEmpty()) {
        state = GameState.ASCEND;
        sendOSC("/phase", 2);
      }
      break;
    case ASCEND:
      // Waiting for the player to press 'E' to ascend
      break;
    case END:
      // Game won; no further updates
      break;
    case LOSE:
      // Game lost; no further updates
      break;
  }
  
  // Trigger lose state if health (50 - glitchLevel) depletes
  if (50 - glitchLevel <= 0 && state != GameState.LOSE) {
    state = GameState.LOSE;
  }
}

void initLevel() {
  println("Loading Level: " + levelNames[levelIdx]);
  state = GameState.SWEEP;  // reset state for the level
  sendOSC("/phase", 0);     // notify MAX of new level
  playerPos = new PVector(CANVAS_W/2, CANVAS_H/2);
  demons = new ArrayList<Enemy>();
  hotspots = new ArrayList<Hotspot>();
  glitchLevel = 0;
  
  // Set the current weapon based on level
  switch(levelIdx) {
    case 0:
      weaponImg = bowImg;
      weaponName = "Bow Array";
      break;
    case 1:
      weaponImg = tazerImg;
      weaponName = "Radiowave Tazer";
      break;
    case 2:
      weaponImg = LRADImg;
      weaponName = "LRAD";
      break;
  }
  
  // Create hotspots at fixed positions (you can later randomize these)
  hotspots.add(new Hotspot(new PVector(150, 150)));
  hotspots.add(new Hotspot(new PVector(CANVAS_W - 150, 150)));
  hotspots.add(new Hotspot(new PVector(CANVAS_W/2, CANVAS_H - 150)));
  
  showTitle = true;
  titleStart = millis();
}

void spawnWave() {
  int count = 3 + levelIdx;  // increase enemy count with level
  for (int i = 0; i < count; i++) {
    PVector spawnPos = randomPositionSafe();
    PImage dImg = imgDemons[int(random(imgDemons.length))];  // choose a random demon image
    demons.add(new Enemy(spawnPos, dImg));
  }
}
