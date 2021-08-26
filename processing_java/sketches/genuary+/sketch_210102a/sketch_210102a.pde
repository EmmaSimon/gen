import nice.palettes.*;
import gifAnimation.*;

// Declare the main ColorPalette object
ColorPalette palette;
boolean isLooping = false;
boolean isLeft = false;
boolean isRight = false;
boolean isUp = false;
boolean isDown = false;
boolean isShifted = false;
boolean isCtrled = false;
boolean isTrailing = false;
boolean isGrowing = false;
boolean isGifMaking = false;
float rx = 0;
float ry = 0;
int cellLength = 5;
long seed = (long) random(99999);

boolean[][][] cells = new boolean[cellLength][cellLength][cellLength];

GifMaker gifExport;

void setup() {
  size(500,500,P3D);
  palette = new ColorPalette(this);
  palette.getPalette();
  lights();
  smooth(8);
  noFill();
  noiseSeed(seed);
  //noLoop();
  noStroke();
  
  seedCells();
}

void seedCells() {
  int z = 0, t = 0, c = 0;
  boolean[][][] newCells = new boolean[cellLength][cellLength][cellLength];
  while (z < cellLength) {
    while (t < cellLength) {
      while (c < cellLength) {
        if (z == 0 && t == 0) {
          newCells[z][t][c] = noise(c) > .5 ? true : false;
        } else {
          boolean[] prev = z == 0 ? newCells[z][t-1] : newCells[z-1][t];
          int lIndex = c == 0 ? cellLength - 1 : c - 1;
          int rIndex = c == cellLength - 1 ? 0 : c + 1;
          newCells[z][t][c] = prev[lIndex] ^ (prev[c] || prev[rIndex]);
        }
        c++;
      }
      t++;
      c = 0;
    }
    z++;
    t = 0;
  }
  cells = newCells;
}

void growCells() {
  int z = 0, t = 0, c = 0;
  boolean[][][] newCells = new boolean[cellLength][cellLength][cellLength];
  while (z < cellLength) {
    while (t < cellLength) {
      while (c < cellLength) {
        boolean[] prev = cells[z][t];
        int lIndex = c == 0 ? cellLength - 1 : c - 1;
        int rIndex = c == cellLength - 1 ? 0 : c + 1;
        newCells[z][t][c] = prev[lIndex] ^ (prev[c] || prev[rIndex]);
        c++;
      }
      t++;
      c = 0;
    }
    z++;
    t = 0;
  }
  cells = newCells;
}

void spin() {
  float click = isShifted ? .5 : 12;
  if (isCtrled) {
    click = 24;
  }
  if (isLeft) {
    ry = ry - click;
  }
  if (isRight) {
    ry = ry + click;
  }
  if (isDown) {
    rx = rx - click;
  }
  if (isUp) {
    rx = rx + click;
  }
  if (isLooping) {
    rx = rx + .2;
    ry = ry + .2;
  }
}

float getT(float uSize, int cellLength, int i) {
  float minPos = (-uSize * (cellLength))/2;
  float maxPos = (uSize * (cellLength))/2;
  float indexRatio = (float) i / (cellLength);
  return lerp(minPos, maxPos, indexRatio) + (uSize /2); //<>//
}

void draw() {
  if (!isTrailing) {
    background(palette.colors[4]);
  }
  float uSize = min(width, height) / (cellLength + 1);
  //pushMatrix();
  translate(width/2, height/2, -500);
  lights();
  //translate(0, uSize, 0);
  //rotateZ(radians(45));
  
  rotateX(radians(rx));
  rotateY(radians(ry));
  
  int z = 0, t = 0, c = 0;
  
  //translate(-width/2, -height/2 + uSize, 500);
  while (z < cellLength) {
    while (t < cellLength) {
      while (c < cellLength) {
        pushMatrix(); 
        translate(getT(uSize, cellLength, c), getT(uSize, cellLength, t), getT(uSize, cellLength, z));
        if (cells[z][t][c]) {
          fill(palette.colors[int((z+c+t)%4)]);
          box(uSize); //<>//
        }
        popMatrix();
        c++;
      }
      t++;
      c = 0;
    }
    z++;
    t = 0;
  }
  
  //translate(0,0,500);
  //popMatrix();
  //translate(-uSize * cellLength, -uSize * cellLength, 0);
  
  //translate(displayWidth / 2, displayHeight / 2);
  if (isGifMaking && gifExport != null) {
    gifExport.setDelay(0);
    gifExport.addFrame();
  }

  if (isGrowing && frameCount % 30 == 0) {
    growCells();
  }
  spin();
}

void keyPressed() {
  if (key == 's') {
    background(palette.colors[4]);
    seed = (int) random(99999);
    noiseSeed(seed);
    seedCells();
    redraw();
  } else if (key == 'g') {
    growCells();
    redraw();
  } else if (key == 'f') {
    if (!isGifMaking) {
      gifExport = new GifMaker(this, String.format("cell-%s-%s.gif", seed, millis()));
      gifExport.setRepeat(0);
    } else {
      gifExport.finish();
      gifExport = null;
    }
    isGifMaking = !isGifMaking;
  } else if (key == 'p') {
    palette.getPalette();
    while (palette.colors.length < 5) {
      palette.getPalette();
    }
    background(palette.colors[4]);
    redraw();
  } else if (key == 'i') {
    save(String.format("cell-%s-%s.png", seed, millis()));
  } else if (keyCode == LEFT) {
    isLeft = true;
  } else if (keyCode == RIGHT) {
    isRight = true;
  } else if (key == '.') {
    cellLength += 1;
    seedCells();
  } else if (key == ',') {
    cellLength = max(0, cellLength - 1);
    seedCells();
  } else if (keyCode == UP) {
    isUp = true;
  } else if (keyCode == DOWN) {
    isDown = true;
  } else if (keyCode == SHIFT) {
    isShifted = true;
  } else if (keyCode == ALT) {
    isCtrled = true;
  } else if (key == 'r') {
    isLooping = !isLooping;
  } else if (key == 't') {
    isTrailing = !isTrailing;
  } else if (key == 'o') {
    isGrowing = !isGrowing;
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
