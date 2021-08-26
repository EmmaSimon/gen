import nice.palettes.ColorPalette;
import gifAnimation.*;

// Declare the main ColorPalette object
ColorPalette palette;
int CANVAS_SIZE = 1000;
boolean isLooping = true;
boolean isLeft = false;
boolean isRight = false;
boolean isUp = false;
boolean isDown = false;
boolean isShifted = false;
boolean isCtrled = false;
boolean isTrailing = false;
boolean isGifMaking = false;
float rx = 0;
float ry = 0;
int loopMax = 5;
long seed = (long) random(99999);

GifMaker gifExport;

void setup() {
  size(750,750,P3D);
  palette = new ColorPalette(this);
  palette.getPalette();
  lights();
  smooth(8);
  noFill();
  noiseSeed(seed);
  //noLoop();
  noStroke();
}

float sn(float x) {
  return radians(lerp(-360, 360, noise(x)));
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

void draw() {
  //lights();
  if (!isTrailing) {
    background(palette.colors[4]);
  }
  translate(width / 2, height / 2);
  rotateZ(radians(45));
  rotateX(radians(rx));
  rotateY(radians(ry));
  
  for (float x = 0; x < loopMax; x++) {
    for (float y = 0; y < loopMax; y++) {
      for (float z = 0; z < loopMax; z++) {
        
        pushMatrix();
        float tx,ty,tz;
        tx = sn(x);
        ty = sn(y);
        tz = sn(z);
       
        fill(palette.colors[int(((y))%4)]);
        rotateX(tx);
        rotateY(ty);
        //rotateZ(tz);
        translate(0, 0, 75*tz);
        //sphere(10*((100+tx+ty+tz) % 2));
        sphere(5*((tx)%7));
        popMatrix();
      }
    }
  }

  //translate(displayWidth / 2, displayHeight / 2);
  if (isGifMaking && gifExport != null) {
    gifExport.addFrame();
  }
  spin();
}

void keyPressed() {
  System.out.println(keyCode);
  if (key == 's') {
    background(palette.colors[4]);
    seed = (int) random(99999);
    noiseSeed(seed);
    redraw();
  } else if (key == 'p') {
    palette.getPalette();
    background(palette.colors[4]);
    redraw();
  } else if (key == 'i') {
    save(String.format("spherefield-%s-%s.png", seed, millis()));
  } else if (key == 'g') {
    if (!isGifMaking) {
      gifExport = new GifMaker(this, String.format("spherefield-%s-%s.gif", seed, millis()));
      gifExport.setRepeat(0);
    } else {
      gifExport.finish();
      gifExport = null;
    }
    isGifMaking = !isGifMaking;
  } else if (keyCode == LEFT) {
    isLeft = true;
  } else if (keyCode == RIGHT) {
    isRight = true;
  } else if (key == '.') {
    loopMax += 1;
  } else if (key == ',') {
    loopMax = max(0, loopMax - 1);
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
  } else if (key == 't') {
    isTrailing = !isTrailing;
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
