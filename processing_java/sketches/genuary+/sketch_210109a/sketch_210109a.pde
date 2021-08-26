
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
int noiseTypeIndex = 0;
FastNoiseLite.NoiseType[] noiseTypes = {
  FastNoiseLite.NoiseType.OpenSimplex2S,
  FastNoiseLite.NoiseType.Cellular,
  FastNoiseLite.NoiseType.Perlin,
  FastNoiseLite.NoiseType.ValueCubic
};
int fractalTypeIndex = 0;
FastNoiseLite.FractalType[] fractalTypes = {
  FastNoiseLite.FractalType.None,
  FastNoiseLite.FractalType.FBm,
  FastNoiseLite.FractalType.Ridged,
  FastNoiseLite.FractalType.PingPong,
  FastNoiseLite.FractalType.DomainWarpProgressive,
  FastNoiseLite.FractalType.DomainWarpIndependent
};

int[] palette;
ArrayList<int[]> paletteHistory = new ArrayList();
int paletteIndex = 0;

int maxLines = 9;
int maxRots = 3;
int frameOffset = 0;

boolean isPaused = false;
boolean isRecording = false;
boolean shouldDraw0s = true;
boolean usebezLines = true;
boolean isRotating = true;

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
  for (int i = newPalette.length - 1; i > 0; i--) {
    int swapIndex = int(random(i + 1));
    // Simple swap
    int a = newPalette[swapIndex];
    newPalette[swapIndex] = newPalette[i];
    newPalette[i] = a;
  }
  paletteHistory.add(newPalette);
  palette = newPalette;
}

void switchNoise(int index) {
  n.SetNoiseType(noiseTypes[constrain(index, 0, noiseTypes.length - 1)]);
}
void switchFractal(int index) {
  n.SetFractalType(fractalTypes[constrain(index, 0, fractalTypes.length - 1)]);
}

void setup () {
  // size(1080, 1920);
  size(750,750);
  // fullScreen();
  seedHistory.add(seed);
  n = new FastNoiseLite(seed);
  n.SetNoiseType(FastNoiseLite.NoiseType.OpenSimplex2S);
  colorHarmony = new ColorHarmony(this);
  paletteGen = new ColorPalette(this);
  switchPalette(1);
  strokeWeight(.5);
  noFill();
  if (isPaused) {
    noLoop();
  }
  videoExport = new VideoExport(this);
}

void drawLine(float x, float skew) {
  if (usebezLines) {
    bezier(
      x, -height * 2,
      x + (skew*3), -height * 2,
      // c < 0 ? cosR : sinR, c < 0 ? sinR : cosR,
      // c >= 0 ? cosR : sinR, c >= 0 ? sinR : cosR,
      x - (skew*3), height * 2,
      x, height * 2
    );
  } else {
    line(x, -height * 2, x, height * 2);
  }
}

void draw() {
  background(palette[0]);
  translate(width/2, height/2);
  pushMatrix();
  int scale = 666;
  int speed = 200;

  int frame = frameCount - frameOffset + 1000000;
  if (isRotating) {
    rotate(-frame*.00420);
  }
  float prevLine = 0;
  for (int c = 0; c <= maxLines; c++) {
    float lineDist = map(n.GetNoise(frame * .01, c * 500 + (frame*.5)), -1, 1, -width/(4*maxLines), width/maxLines + 15);
    if (c == 0 && !shouldDraw0s) {
      prevLine += lineDist;
      continue;
    }
    // float noise = ;
    stroke(lerpColors(norm(n.GetNoise((frame * .1) + c, c * 100 + (frame*.8)) * 2, -1, 1), palette[1], palette[2], palette[3], palette[4]));
    // rotate(TAU/maxLines);
    pushMatrix();

    // float x = (c * 6) + ((c < 0 ? -1 : 1) * lineDist);

    for (int cloneRot = 0; cloneRot < maxRots; cloneRot++) {
      rotate(TAU/(maxRots));
      // System.out.println("x: "+x + " c: " + c + " l: " + lineDist);
      // if (abs(c) < 5 && cloneRot == 0) {
      //   println(
      //     "c: "+ c +
      //     " x: "+ x +
      //     " lineDist: "+ lineDist
      //   );
      // }
      drawLine(prevLine, prevLine*lineDist/c);
      if (c == 0) {
        continue;
      }
      pushMatrix();
      rotate(TAU/2);
      drawLine(prevLine, -prevLine*lineDist/c);
      popMatrix();

    }
    popMatrix();
    prevLine += lineDist;
  }
  popMatrix();
  if (isRecording) {
    videoExport.saveFrame();
  }
}

color lerpColors(float amt, color... colors) {
  if(colors.length==1){ return colors[0]; }
  float cAmt = constrain(amt, 0, 1);
  float cunit = 1.0/(colors.length - 1);
  int downIndex = floor(cAmt / cunit);
  int upIndex = ceil(cAmt / cunit);
  return lerpColor(colors[downIndex], colors[upIndex], cAmt%cunit/cunit);
}

void keyPressed() {
  int now = millis();
  System.out.println("keypressing " + key + " @ " + now);
  // if (now - lastPressed < 100) {
  //     lastPressed = now;
  //     return;
  // }

  if (key == ']') {
      seedIndex++;
      if (seedIndex == seedHistory.size()) {
          seedHistory.add(seed + floor(lerp(-2000, 2000, n.GetNoise(lastPressed, seed))));
      }
      seed = seedHistory.get(seedIndex);
      n.SetSeed(seed);
      frameOffset = frameCount;
      System.out.println("new seed: " + seed);
      redraw();
  } else if (key == '[') {
      seedIndex = max(0, seedIndex - 1);
      seed = seedHistory.get(seedIndex);
      n.SetSeed(seed);
      frameOffset = frameCount;
      System.out.println("prev seed: " + seed);
      redraw();
  } else if (key == '}') {
    switchPalette(paletteIndex + 1);
  } else if (key == '{') {
    switchPalette(max(0, paletteIndex - 1));
  } else if (key == 'n') {
    noiseTypeIndex = (noiseTypeIndex + 1) % noiseTypes.length;
    switchNoise(noiseTypeIndex);
  } else if (key == 'N') {
    noiseTypeIndex = noiseTypeIndex == 0 ? noiseTypes.length - 1 : noiseTypeIndex - 1;
    switchNoise(noiseTypeIndex);
  } else if (key == 'm') {
    fractalTypeIndex = (fractalTypeIndex + 1) % fractalTypes.length;
    switchFractal(fractalTypeIndex);
  } else if (key == 'M') {
    fractalTypeIndex = fractalTypeIndex == 0 ? fractalTypes.length - 1 : fractalTypeIndex - 1;
    switchFractal(fractalTypeIndex);
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
      videoExport.setMovieFileName(String.format("interfere-%s-%s.mp4", seed, millis()));
      videoExport.startMovie();
    } else {
      videoExport.endMovie();
    }
  } else if (key == '0') {
    shouldDraw0s = !shouldDraw0s;
  } else if (key == 'l') {
    usebezLines = !usebezLines;
  } else if (key == 'o') {
    isRotating = !isRotating;
  } else if (keyCode == UP || key == 'w') {
    maxLines++;
  } else if (keyCode == DOWN || key == 's') {
    maxLines = max(1, maxLines - 1);
  } else if (keyCode == RIGHT || key == 'd') {
    maxRots++;
  } else if (keyCode == LEFT || key == 'a') {
    maxRots = max(1, maxRots - 1);
  }
  lastPressed = now;
}
