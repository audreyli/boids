ArrayList<Boid> boids;
ArrayList<PVector> obstacles;

void setup() {
  size(640, 360);
  boids = new ArrayList<Boid>();
  obstacles = new ArrayList<PVector>();
  obstacles.add(new PVector(100, 100));
  obstacles.add(new PVector(540, 100));
  obstacles.add(new PVector(100, 260));
  obstacles.add(new PVector(540, 260));
  obstacles.add(new PVector(320, 100));
  obstacles.add(new PVector(320, 260));
  for (int i = 0; i < 30; i++) {
    boids.add(new Boid(width/2, height/2));
  }
}

void draw() {
  background(50, 50, 200);
  for (Boid b : boids) {
    b.run();
  }
  for (PVector o : obstacles) {
    fill(204, 28, 28);
    noStroke();
    pushMatrix();
    translate(o.x, o.y);
    ellipse(0, 0, 8, 8);
    endShape();
    popMatrix();
  }
}

void mousePressed() {
  boids = new ArrayList<Boid>();
  for (int i = 0; i < 30; i++) {
    boids.add(new Boid(width/2, height/2));
  }
}

// The Boid class
class Boid {
  PVector pos;
  PVector vel;
  PVector acc;
  float r;
  float maxspeed;
  float maxforce;

  Boid(float x, float y) {
    pos = new PVector(x, y);
    vel = PVector.random2D();
    acc = new PVector(0, 0);
    r = 4.0;
    maxspeed = 2;
    maxforce = 0.03;
  }

  void run() {
    flock();
    update();
    render();
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
    //float theta = vel.heading() + radians(90);
    
    fill(255, 100);
    stroke(255);
    pushMatrix();
    translate(pos.x, pos.y);
    //rotate(theta);
    //beginShape(TRIANGLES);
    //vertex(0, -r*2);
    //vertex(-r, r*2);
    //vertex(r, r*2);
    ellipse(0, 0, r, r);
    endShape();
    popMatrix();
  }

  PVector separate() {
    float desiredseparation = 25.0f;
    PVector steer = new PVector(0, 0, 0);
    int count = 0;
    for (Boid other : boids) {
      float d = PVector.dist(pos, other.pos);
      if ((d > 0) && (d < desiredseparation)) {
        PVector diff = PVector.sub(pos, other.pos);
        diff.normalize();
        diff.div(d);
        steer.add(diff);
        count++;
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
      float d = PVector.dist(pos, other.pos);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.vel);
        count++;
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
      float d = PVector.dist(pos, other.pos);
      if ((d > 0) && (d < neighbordist)) {
        sum.add(other.pos);
        count++;
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
    return steer;
  }
}