// Hotspot class: defines a hotspot that triggers enemy waves when the player enters it.
class Hotspot {
  PVector pos;   // position
  boolean cleared = false;  // whether it has been triggered
  
  Hotspot(PVector p) {
    pos = p.copy();
  }
  
  // Render the hotspot if not already cleared
  void draw() {
    if (!cleared) {
      noFill();
      stroke(0, 200, 255);
      rectMode(CENTER);
      rect(pos.x, pos.y, 40, 40);
    }
  }
}
