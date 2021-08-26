import processing.svg.*;

boolean isLeft = false;
boolean isRight = false;
boolean isUp = false;
boolean isDown = false;
boolean isShifted = false;
boolean isCtrled = false;
boolean isLooping = true;
boolean isTrailing = false;
boolean hasRays = false;
float speed = .001;
int frameRateReset = 0;
long seed = (long) random(99999);
float prevStartAngle = 0;
int maxCycle = 6;

void setup() {
  //fullScreen();
  size(1000, 1000);
  beginRecord(SVG, String.format("tri_%s-%s_%s-%s-%s.svg", month(), day(), hour(), minute(), second()));
  smooth(8);
  noFill();
  background(255);
  noiseSeed(seed);
  strokeWeight(0);
  noLoop();
  
}

void equiTri(float midX, float midY, float r, float angle) {
  float x1 = midX + r * cos(angle);
  float y1 = midY - r * sin(angle);
  float x2 = midX + r * cos(angle + (TAU/3));
  float y2 = midY - r * sin(angle + (TAU/3));
  float x3 = midX + r * cos(angle + (2*TAU/3));
  float y3 = midY - r * sin(angle + (2*TAU/3));
  if (hasRays) {
    line(midX, midY, x1, y1);
    line(midX, midY, x2, y2);
    line(midX, midY, x3, y3);
  }
  triangle(x1, y1, x2, y2, x3, y3);
}

void equiTri(float x, float y, float l, boolean up) {
  equiTri(x,y,l, up ? PI/2 : 3*PI/2);
}

void equiTri(float x, float y, float l) {
  equiTri(x,y,l, true);
}

float angle(float pa, int cycle) {
  if (cycle == 1) {
    return pa + speed;
  }
  return (pa + lerp(-PI/2, PI/2, noise(cycle, pa, speed*(frameCount-frameRateReset))));
}

float radius(float a, float pa, float pr) {
  if (pr == 0) {
    return noise(pa, speed*(frameCount-frameRateReset))*55;
    //return speed*(frameCount-frameRateReset+.01)/55;
  }
  float theta = abs(a - pa) % (PI/2);
  return pr * (sqrt(3) * sin(theta) + cos(theta));
}

void tricycle() {
  int cycle = 1;
  float prevRadius = 0;
  float prevAngle = prevStartAngle;
  while (cycle > 0) {
    print("drawing triangle ", cycle);
    float a = angle(prevAngle, cycle);
    float r = radius(a, prevAngle, prevRadius);
    equiTri(0,0, r, a);
    
    prevAngle = a;
    prevRadius = r;
    if (cycle == 1) {
      prevStartAngle = prevAngle;
    }
    cycle = cycle < maxCycle ? cycle + 1 : 0;
  }
}

void draw() {
  translate(width / 2, height / 2);
  stroke(0);
  int maxLoops = 6;
  int loop = 0;
  while (loop < maxLoops) {
    seed = (int) random(99999);
    noiseSeed(seed);
    tricycle();
    loop++;
  }
  
  endRecord();
  exit();
}

void keyPressed() {
  if (key == 's') {
    //background(255);
    seed = (int) random(99999);
    noiseSeed(seed);
    redraw();
  } else if (key == 'v') {

  } else if (key == 'i') {
    String name = String.format("tri-%s-%s.png", seed, millis());
    System.out.println(String.format("Saving %s", name));
    save(name);
  } else if (keyCode == LEFT) {
    isLeft = true;
  } else if (keyCode == RIGHT) {
    isRight = true;
  } else if (key == '.') {
    maxCycle += 1;
  } else if (key == ',') {
    maxCycle = max(0, maxCycle - 1);
  } else if (keyCode == UP) {
    isUp = true;
  } else if (keyCode == DOWN) {
    isDown = true;
  } else if (keyCode == SHIFT) {
    isShifted = true;
  } else if (keyCode == ALT) {
    isCtrled = true;
  } else if (key == 'f') {
    isLooping = !isLooping;
    if (isLooping) {
      loop();
    } else {
      noLoop();
    }
  } else if (key == 't') {
    isTrailing = !isTrailing;
  } else if (key == 'r') {
    hasRays = !hasRays;
  } else if (key == 'b') {
    frameRateReset = frameCount;
  }
}

void keyReleased() {
  if (keyCode == SHIFT) {
    isShifted = false;
  } else if (keyCode == ALT) {
    isCtrled = false;
  } else if (keyCode == LEFT) {
    isLeft = false;
  } else if (keyCode == RIGHT) {
    isRight = false;
  } else if (keyCode == UP) {
    isUp = false;
  } else if (keyCode == DOWN) {
    isDown = false;
  }
}
