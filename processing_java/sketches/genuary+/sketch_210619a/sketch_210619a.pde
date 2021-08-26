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
  size(777, 777, P3D);
  frameRate(60);

  smooth(8);
  noFill();
  hint(ENABLE_DEPTH_SORT);
  background(255);
  noiseSeed(seed);
  strokeWeight(1);
  noLoop();
}

void pyramid(float vSize) {

  stroke(0);

  // this pyramid has 4 sides, each drawn as a separate triangle
  // each side has 3 vertices, making up a triangle shape
  // the parameter " t " determines the size of the pyramid
  beginShape(TRIANGLE_STRIP);
  vertex( vSize,  vSize,  vSize); // v1
  vertex(-vSize, -vSize,  vSize); // v2
  vertex(-vSize,  vSize, -vSize); // v3
  vertex( vSize, -vSize, -vSize); // v4

  vertex( vSize,  vSize,  vSize); //v1 again
  vertex(-vSize, -vSize,  vSize); //v2 again
  endShape();
}

void draw() {
  //background(255);
  beginRaw(SVG, String.format("cube_%s-%s_%s-%s-%s.svg", month(), day(), hour(), minute(), second()));
  translate(width / 2, height / 2, 0);
  float circleWidth = 20;
  float circleSpacing = circleWidth;
  float boxCount = 149;
  float offset = circleWidth / 2;
  for (int c = 2; c < boxCount; c++) {
    push();
    // if (c == 0) {
    //   rotateX(PI/2);
    //   rotateY(PI/2);
    //   rotateZ(PI/2);
    // } else {
      float x = cos((c/TAU));
      float y = sin((c/TAU));
      float z = (cos(((c/PI)/TAU)));
      // print(String.format("x %s\ny %s\nz %s\n\n", x,y,z));
      rotateX(x);
      rotateY(y);
      rotateZ(z);
      // rotateZ(PI*c/4);
    // }
    // box(3* log(2*c));
    pyramid(2 * log(c) + 2.5);
    pop();

    translate(-7/log(2*c) * c * cos(1*c/1.5), -7/log(2*c) * c * sin(1*c/1.5));

     // for (int y = 0; y < gridHeight; y++) {
      //float xPos = c * circleSpacing;
      //float yPos = y * circleSpacing;
      //float jitter = (noise(xPos * .5, yPos * .5) - .5) * 10;
      //float jitter = pow(c, 2) * pow(y, 2) * .009;
      //float jitter = cos(c * y) * 10;
      // float jitter = sin(exp(c) * exp(y)) * 22;
      float jitter = tan(TAU / (c+.1)) * c;
      // circle(xPos + jitter, yPos + jitter, circleWidth);
      // circle(xPos + offset + jitter, yPos + offset + jitter, circleWidth);
      // circle(-xPos - jitter, -yPos - jitter, circleWidth);
      // circle(-xPos - offset - jitter, -yPos - offset - jitter, circleWidth);
      // circle(-xPos - jitter, yPos + jitter, circleWidth);
      // circle(-xPos - offset - jitter, yPos + offset + jitter, circleWidth);
      // circle(xPos + jitter, -yPos - jitter, circleWidth);
      // circle(xPos + offset + jitter, -yPos - offset - jitter, circleWidth);
     // }
  }

  endRaw();
  exit();
}

void keyPressed() {
  if (key == 's') {
    background(255);
    clear();
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
