import com.cage.colorharmony.ColorHarmony;
import nice.palettes.*;
import com.hamoid.*;

VideoExport videoExport;
FastNoiseLite n;
PFont font;
ColorHarmony colorHarmony;
ColorPalette paletteGen;


int lastPressed = 0;

int seed = 420;
ArrayList<Integer> seedHistory = new ArrayList();
int seedIndex = 0;

int[] palette;
ArrayList<int[]> paletteHistory = new ArrayList();
int paletteIndex = 0;

int maxCurves = 18;
int maxRots = 3;
int frameOffset = 0;

boolean isPaused = true;
boolean isRecording = false;

void switchPalette(int index) {
  paletteIndex = index;
  if (index < paletteHistory.size()) {
    palette = paletteHistory.get(index);
    return;
  }
  paletteGen.getPalette();
  while (paletteGen.colors.length < 5) {
    paletteGen.getPalette();
  }
  int[] newPalette = paletteGen.colors;
  paletteHistory.add(paletteGen.colors);
  palette = newPalette;
}

void setup () {
  //size(1080, 1920);
  // size(750,750);
  fullScreen();
  seedHistory.add(seed);
  n = new FastNoiseLite(seed);
  n.SetNoiseType(FastNoiseLite.NoiseType.OpenSimplex2S);
  colorHarmony = new ColorHarmony(this);
  paletteGen = new ColorPalette(this);
  switchPalette(1);
  strokeWeight(2);
  noFill();
  if (isPaused) {
    noLoop();
  }
  videoExport = new VideoExport(this);
}

void draw() {
  background(palette[0]);
  translate(width/2, height/2);
  pushMatrix();
  int scale = 666;
  int speed = 200;

  int frame = frameCount - frameOffset;
  rotate(-frame*.00420);
  for (int c = 0; c < maxCurves; c++) {
    float r = n.GetNoise(c * 3, (frame*.666 + 1000000));
    stroke(lerpColors(norm(n.GetNoise(c*3, frame), -1, 1), palette[1], palette[2], palette[3], palette[4]));
    float sinR = r * 2 * sin(r * (frame + 5000) * .0001) * scale;
    float cosR = r * 2 * cos(r * (frame + 5000) * .001) * scale;
    rotate(TAU/maxCurves);
    pushMatrix();
    for (int cloneRot = 0; cloneRot < maxRots; cloneRot++) {
      rotate(TAU/maxRots);
      bezier(
        0, 33,
        c < 0 ? cosR : sinR, c < 0 ? sinR : cosR,
        c >= 0 ? cosR : sinR, c >= 0 ? sinR : cosR,
        0, 33
      );
    }
    popMatrix();
  }
  popMatrix();
  if (isRecording) {
    videoExport.saveFrame();
  }
}

color lerpColors(float amt, color... colors) {
  if(colors.length==1){ return colors[0]; }
  float cunit = 1.0/(colors.length-1);
  return lerpColor(colors[floor(amt / cunit)], colors[ceil(amt / cunit)], amt%cunit/cunit);
}

void keyPressed() {
  int now = millis();
  System.out.println("keypressing " + key + " @ " + now);
  if (now - lastPressed < 100) {
      lastPressed = now;
      return;
  }

  if (key == ']') {
      seedIndex++;
      if (seedIndex == seedHistory.size()) {
          seedHistory.add(seed + floor(lerp(-2000, 2000, n.GetNoise(lastPressed, seed))));
      }
      seed = seedHistory.get(seedIndex);
      n.SetSeed(seed);
      System.out.println("new seed: " + seed);
      redraw();
  } else if (key == '[') {
      seedIndex = max(0, seedIndex - 1);
      seed = seedHistory.get(seedIndex);
      n.SetSeed(seed);
      System.out.println("prev seed: " + seed);
      redraw();
  } else if (key == '}') {
    switchPalette(paletteIndex + 1);
  } else if (key == '{') {
    switchPalette(max(0, paletteIndex - 1));
  } else if (key == 'b') {
    frameOffset = frameCount;
  } else if (key == 'p') {
    isPaused = !isPaused;
    if (isPaused) {
      noLoop();
    } else {
      loop();
    }
  } else if (key == 'r') {
    isRecording = !isRecording;
    if (isRecording) {
      videoExport.setMovieFileName(String.format("bezspin-%s-%s.mp4", seed, millis()));
      videoExport.startMovie();
    } else {
      videoExport.endMovie();
    }
  } else if (keyCode == UP || key == 'w') {
    maxCurves++;
  } else if (keyCode == DOWN || key == 's') {
    maxCurves = max(1, maxCurves - 1);
  } else if (keyCode == RIGHT || key == 'd') {
    maxRots++;
  } else if (keyCode == LEFT || key == 'a') {
    maxRots = max(1, maxRots - 1);
  }
  lastPressed = now;
}
