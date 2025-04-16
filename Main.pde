import oscP5.*;
import netP5.*;

final int CANVAS_W = 800, CANVAS_H = 600;
final int TITLE_TIME   = 3000;  
final int TRANSIT_TIME = 3000;  // time to display stairs background
final int PLAYER_SIZE  = 160;   // size of maincharacter.jpg
final int DEMON_SIZE   = 100;   // demon image size

enum GameState { SWEEP, FIGHT, ASCEND, END, LOSE }  
// END state: win, LOSE state: player loses

// Global OSC and network objects
OscP5 osc;
NetAddress maxAddr;

// Global game variables
PVector playerPos;
ArrayList<Enemy> demons;
ArrayList<Hotspot> hotspots;

// Finite state machine and level data
GameState state;
int levelIdx;            // current level index
float glitchLevel;       // internal glitch level, used for OSC and difficulty

boolean showIntro   = true;
boolean showTitle   = false;
boolean inTransit   = false;
int introStart;
int titleStart;
int transitStart;

// Levels
String[] levelNames = { "Broadcast Room", "Master Control", "Roof Finale" };

// Assets
PImage imgPlayer;
PImage[] imgDemons = new PImage[4];
PImage bgIntro, bgBroadcast, bgControl, bgRoof, bgStairs;

// New weapon assets
PImage bowImg, tazerImg, LRADImg;
PImage weaponImg;
String weaponName;

void settings() {
  // Using P3D (needed for Syphon if you later add it, and for GPU acceleration)
  size(CANVAS_W, CANVAS_H, P3D);
}

void setup() {
  textAlign(CENTER, CENTER);
  textSize(32);

  // OSC Setup – modify as needed
  osc = new OscP5(this, 9000);
  maxAddr = new NetAddress("127.0.0.1", 8000);

  // Load main assets
  imgPlayer = loadImage("maincharacter.jpg");    // main character image
  imgDemons[0] = loadImage("demon1.jpg");           // demon images
  imgDemons[1] = loadImage("demon2.jpg");
  imgDemons[2] = loadImage("demon3.jpg");
  imgDemons[3] = loadImage("demon4.jpg");
  
  bgIntro     = loadImage("intro.jpg");
  bgBroadcast = loadImage("broadcast_room.jpg");
  bgControl   = loadImage("control_room.jpg");
  bgRoof      = loadImage("roof.jpg");
  bgStairs    = loadImage("stairs.jpg");
  
  // Load weapon images
  bowImg    = loadImage("bow_array.png");
  tazerImg  = loadImage("phased_array_lazer.png");
  LRADImg   = loadImage("LRAD.png");
  
  // Start with the intro
  introStart = millis();
  initLevel();
}

void draw() {
  float dt = 1.0 / max(frameRate, 1);
  
  if (showIntro) {
    drawIntro();
    return;
  }
  
  if (inTransit) {
    drawTransit();
    return;
  }
  
  handleInput();
  updateWorld(dt);
  renderWorld();
  sendOSC();
}

// OSC communication
void sendOSC() {
  sendOSC("/glitchLevel", glitchLevel);
  
  float demonProx = 0;
  for (Enemy d : demons) {
    float distVal = PVector.dist(d.pos, playerPos);
    demonProx = max(demonProx, 1 - constrain(distVal / 100.0, 0, 1));
  }
  sendOSC("/demonProx", demonProx);
}

void sendOSC(String addr, float val) {
  OscMessage msg = new OscMessage(addr);
  msg.add(val);
  osc.send(msg, maxAddr);
}

// Returns the background image based on the current level
PImage getLevelBG() {
  if (levelIdx == 0) return bgBroadcast;
  if (levelIdx == 1) return bgControl;
  return bgRoof;  // for levelIdx == 2
}

// Utility: find a random safe position (non-overlapping)
PVector randomPositionSafe() {
  for (int t = 0; t < 50; t++) {
    PVector p = new PVector(random(70, CANVAS_W - 70), random(70, CANVAS_H - 70));
    boolean collision = false;
    for (Enemy d : demons) {
      if (PVector.dist(p, d.pos) < 60) {
        collision = true;
        break;
      }
    }
    if (!collision) return p;
  }
  return new PVector(width/2, height/2);
}
