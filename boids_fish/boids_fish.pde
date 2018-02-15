ArrayList<Boid> boids;
ArrayList<PVector> obstacles;
Predator pred;
boolean predExists = false;
PImage bg;
PImage fish;
PImage fishflip;
PImage predator;
PImage predatorflip;

void setup() {
  size(640, 360);
  bg = loadImage("bg.png");
  fish = loadImage("fish.png");
  fishflip = loadImage("fishflip.png");
  predator = loadImage("predator.png");
  predatorflip = loadImage("predatorflip.png");
  boids = new ArrayList<Boid>();
  obstacles = new ArrayList<PVector>();
  addObstacles();
  for (int i = 0; i < 30; i++) {
    boids.add(new Boid(width/2, height/2));
  }
}

void draw() {
  image(bg, 0, 0, 640, 360);
  for (Boid b : boids) {
    b.run();
  }
  if (predExists) {
    pred.run();
  }
}

void mousePressed() {
  pred = new Predator(mouseX, mouseY);
  predExists = true;
}

void addObstacles() {
  int wall = 60;
  for (int i = 0; i < width; i = i + 5) {
    obstacles.add(new PVector(i, 0 - wall));
    obstacles.add(new PVector(i, height - 100 + wall));
  }
}

class Boid {
  PVector pos;
  PVector vel;
  PVector acc;
  float r;
  float maxspeed;
  float maxforce;
  boolean display;

  Boid(float x, float y) {
    pos = new PVector(x, y);
    vel = PVector.random2D();
    acc = new PVector(0, 0);
    r = 4.0;
    maxspeed = 2;
    maxforce = 0.03;
    display = true;
  }

  void run() {
    flock();
    update();
    if (display) {
      render();
    }
  }

  void flock() {
    acc.add(separate().mult(1.5));
    acc.add(align().mult(1.0));
    acc.add(obstacles().mult(2.0));
    acc.add(cohesion().mult(1.0));
  }

  void update() {
    vel.add(acc);
    vel.limit(maxspeed);
    pos.add(vel);
    if (pos.x <= 0) {
      pos.x += width;
    }
    if (pos.x >= width) {
      pos.x -= width;
    }
    acc = new PVector(0, 0);
  }

  PVector seek(PVector target) {
    PVector desired = PVector.sub(target, pos);
    desired.setMag(maxspeed);
    PVector steer = PVector.sub(desired, vel);
    steer.limit(maxforce);
    return steer;
  }

  void render() {
    float scale = 0.5;
    fill(255, 100);
    stroke(255);
    pushMatrix();
    translate(pos.x, pos.y);
    if (vel.x >= 0) {
      image(fish, 0, 0, 58*scale, 28*scale);
    } else {
      image(fishflip, 0, 0, 58*scale, 28*scale);
    }
    popMatrix();
  }

  PVector separate() {
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    for (Boid other : boids) {
      if (other.display) {
        float d = PVector.dist(pos, other.pos);
        if ((d > 0) && (d < desiredseparation)) {
          PVector diff = PVector.sub(pos, other.pos);
          diff.normalize();
          diff.div(d);
          steer.add(diff);
          count++;
        }
      }
    }
    if (count > 0) {
      steer.div((float)count);
    }
    if (steer.mag() > 0) {
      steer.setMag(maxspeed);
      steer.sub(vel);
      steer.limit(maxforce);
    }
    return steer;
  }

  PVector align() {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Boid other : boids) {
      if (other.display) {
        float d = PVector.dist(pos, other.pos);
        if ((d > 0) && (d < neighbordist)) {
          sum.add(other.vel);
          count++;
        }
      }
    }
    if (count > 0) {
      sum.div((float)count);
      sum.setMag(maxspeed);
      PVector steer = PVector.sub(sum, vel);
      steer.limit(maxforce);
      return steer;
    } 
    else {
      return new PVector(0, 0);
    }
  }

  PVector cohesion() {
    float neighbordist = 50;
    PVector sum = new PVector(0, 0);
    int count = 0;
    for (Boid other : boids) {
      if (other.display) {
        float d = PVector.dist(pos, other.pos);
        if ((d > 0) && (d < neighbordist)) {
          sum.add(other.pos);
          count++;
        }
      }
    }
    if (count > 0) {
      sum.div(count);
      return seek(sum);
    } 
    else {
      return new PVector(0, 0);
    }
  }
  
  PVector obstacles() {
    int avoidRadius = 80;
    PVector steer = new PVector(0, 0);

    for (PVector other : obstacles) {
      float d = PVector.dist(pos, other);
      if ((d > 0) && (d < avoidRadius)) {
        PVector diff = PVector.sub(pos, other);
        diff.normalize();
        diff.div(d);
        steer.add(diff);
      }
    }
    if (predExists) {
      float d = PVector.dist(pos, pred.pos);
      if (d < 50) {
        display = false;
      }
      if ((d > 0) && (d < avoidRadius*1.5)) {
        PVector diff = PVector.sub(pos, pred.pos);
        diff.normalize();
        diff.div(d);
        steer.add(diff.mult(10));
      }
      
    }
    return steer;
  }
}

class Predator {
  PVector pos;
  PVector vel;

  Predator(float x, float y) {
    pos = new PVector(x, y);
    vel = new PVector(random(1, 2), 0);
  }
  
  void run() {
    update();
    render();
  }

  void update() {
    pos.add(vel);
    if (pos.x <= 0) {
      pos.x += width;
    }
    if (pos.x >= width) {
      pos.x -= width;
    }
  }

  void render() {
    float scale = 0.5;
    pushMatrix();
    translate(pos.x, pos.y);
    if (vel.x >= 0) {
      image(predator, 0, 0, 128*scale, 106*scale);
    } else {
      image(predatorflip, 0, 0, 128*scale, 106*scale);
    }
    popMatrix();
  }
}