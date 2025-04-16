// Enemy class: stores enemy position, velocity, and health.
class Enemy {
  PVector pos, vel;
  int hp = 3;       // initial health points
  PImage img;       // enemy image
  
  Enemy(PVector p, PImage i) {
    pos = p.copy();
    img = i;
    vel = PVector.random2D().mult(0.8);  // initial random velocity
  }
  
  // Act: adjusts behavior based on distance to the player.
  void act(PVector player, float dt) {
    PVector dir = PVector.sub(player, pos);
    if (dir.mag() > 200) {
      // Roam if far from the player
      pos.add(vel);
      if (frameCount % 120 == 0) {
        vel = PVector.random2D().mult(0.5);
      }
    } else {
      // Chase the player
      dir.normalize().mult(1.5);
      pos.add(dir);
    }
  }
  
  // Render the enemy
  void draw() {
    imageMode(CENTER);
    if (img != null) {
      image(img, pos.x, pos.y, DEMON_SIZE, DEMON_SIZE);
    } else {
      fill(255, 0, 0);
      ellipse(pos.x, pos.y, DEMON_SIZE, DEMON_SIZE);
    }
  }
}
