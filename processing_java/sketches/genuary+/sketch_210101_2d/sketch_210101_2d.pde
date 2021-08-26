import nice.palettes.*;

// Declare the main ColorPalette object
ColorPalette palette;
int CANVAS_SIZE = 500;
int loopMax = 5;
int ry = 0;
int seed = (int) random(99999);

void setup() {
  size(500, 500);
  palette = new ColorPalette(this);
  palette.getPalette();
  noiseSeed(seed);
  noFill();
  noLoop();
}

float sn(float x) {
  return lerp(0, CANVAS_SIZE, noise(x));
}

float sn2(float x, float y) {
  return lerp(0, CANVAS_SIZE, noise(x, y));
}

void draw() {
  background(palette.colors[4]);
  translate(CANVAS_SIZE / 2, -CANVAS_SIZE / 4);
  rotate(radians(45));
  rotateY(radians(ry));

  for (float x = 0; x < loopMax; x++) {
    for (float y = 0; y < loopMax; y++) {
      for (float z = 0; z < loopMax; z++) {
        stroke(palette.colors[int(z%4)]);
        bezier(
          sn(x), sn(y),
          sn2(x, z), sn2(y, z),
          sn2(x+1, z), sn2(y+1, z),
          sn(x+1), sn(y+1)
        );
      }
    }
  }
}

void keyPressed() {
  System.out.println(keyCode);
  if (keyCode == 83) {
    seed = (int) random(99999);
    noiseSeed(seed);
    redraw();
  } else if (keyCode == 80) {
    palette.getPalette();
    redraw();
  } else if (keyCode == 73) {
    save(String.format("bezloop-%s.png", seed));
  } else if (keyCode == 38) {
    loopMax += 1;
    redraw();
  } else if (keyCode == 40) {
    loopMax -= 1;
    redraw();
  }
  //} else if (keyCode == 37) {
  //  ry = ry - 10;
  //  if (ry < 0) {
  //    ry = ry + 360;
  //  }
  //  redraw();
  //} else if (keyCode == 39) {
  //  ry = ry + 10;
  //  if (ry > 360) {
  //    ry = ry - 360;
  //  }
  //  redraw();
  //}
}
