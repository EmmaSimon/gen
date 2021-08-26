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
GifMaker gifExport;

void setup() {
  size(750,750);
  //fullScreen();
  palette = new ColorPalette(this);
  palette.getPalette();
  smooth(8);
  noFill();
  noiseSeed(seed);
  noLoop();
  noStroke();
}

void equiTri(float x, float y, float l, boolean up) {
  float h = l * sqrt(3)/2;
  int dir = up ? 1 : -1;
  triangle(x, y, x + (dir * h), y - (l / 2), x + (dir * h), y + (l / 2));
}

void equiTri(float x, float y, float l) {
  equiTri(x,y,l, true);
}

void draw() { //<>//
  background(palette.colors[0]);
  translate(width/2, height/2);
  int rotations = 8;
  int cycles = 20;

  for (int r = 0; r < rotations; r++) {
    fill(palette.colors[r%2 + 3]);
    pushMatrix();
    rotate(radians(r * (360/rotations)));
    for (int c = 5; c < cycles; c++) {
      float xStart = c*10;
      float xBezDiff = lerp(-5, 10, noise(c)) * c;
      float yBez = lerp(-10, 30, noise(c)) * (c/4);
      float xEnd = c*lerp(11, 25, noise(c));
      bezier(xStart, 0, xStart + xBezDiff, yBez, xStart + xBezDiff, yBez, xEnd, 0);
      bezier(xStart, 0, xStart + xBezDiff, -yBez, xStart + xBezDiff, -yBez, xEnd, 0);
    }
    popMatrix();
  }
  for (int r = 0; r < rotations; r++) {
    fill(palette.colors[r%2 + 2]);
    pushMatrix();
    rotate(radians(r * (360/rotations)));
    for (int c = 7; c < cycles; c++) {
      if (noise(c, seed) > .6) {
        equiTri(c*10, 0, lerp(1,7,noise(c)) * c, noise(c) > .5);
      }
    }
    popMatrix();
  }
  for (int r = 0; r < rotations; r++) {
    fill(palette.colors[r%2 + 1]);
    pushMatrix();
    rotate(radians(r * (360/rotations)));
    square(10,10,10);
    for (int c = 4; c < cycles; c++) {
      if (noise(c, seed) < .4) {
        square(c*10, c*10, lerp(.5, 5, noise(c)) * c);
      }
    }
    popMatrix();
  }
}

void keyPressed() {
  if (key == 's') {
    background(palette.colors[4]);
    seed = (int) random(99999);
    noiseSeed(seed);
    redraw();
  } else if (key == 'g') {
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
    redraw();
  } else if (key == 'i') {
    save(String.format("sym-%s-%s.png", seed, millis()));
  }
}
  
