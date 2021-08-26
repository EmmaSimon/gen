import processing.sound.*;
import nice.palettes.ColorPalette;
import com.hamoid.*;

String mbtaApiUrl = "https://api-v3.mbta.com/vehicles?filter%5Broute_type%5D=1"


VideoExport videoExport;
ColorPalette paletteGen;
SoundFile song;
FFT fft;

int[] palette;
ArrayList<int[]> paletteHistory = new ArrayList();
int paletteIndex = 0;

int bands = 16;
float[] spectrum = new float[bands];
float[] displayBands = new float[bands];

boolean isLeft = false;
boolean isRight = false;
boolean isUp = false;
boolean isDown = false;
boolean isShifted = false;
boolean isCtrled = false;
boolean isLooping = true;
boolean isTrailing = false;
boolean isRecording = true;
boolean hasRays = false;
// float speed = .001;
// int frameRateReset = 0;
// long seed = (long) random(99999);
float prevStartAngle = 0;
int maxCycle = 33;

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

void setup() {
  // fullScreen();
  size(750, 750);
  paletteGen = new ColorPalette(this);
  switchPalette(0);
  videoExport = new VideoExport(this);
  videoExport.setFrameRate(30);
  smooth(8);
  noFill();
  // noiseSeed(seed);
  strokeWeight(3);
  if (!isLooping) {
    noLoop();
  }
  fft = new FFT(this, bands);
  song = new SoundFile(this, "song.wav");
  song.play();
  fft.input(song);
  if (isRecording) {
    videoExport.setMovieFileName(String.format("audio-tri--%s.mp4", millis()));
    videoExport.setAudioFileName("song.wav");
    videoExport.startMovie();
  }
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

float angle(float pa, int cycle, float v) {
  // if (cycle == 0) {
  //   return pa + speed;
  // }
  boolean even = cycle % 2 == 0;
  return (pa + lerp(0, even ? PI/2 : -PI/2, v));
}

float radius(float a, float pa, float pr) {
  if (pr == 0) {
    return 20;
    // return noise(pa, speed*(frameCount-frameRateReset))*55;
    //return speed*(frameCount-frameRateReset+.01)/55;
  }
  float theta = abs(a - pa) % (PI/2);
  return pr * (sqrt(3) * sin(theta) + cos(theta));
}

void draw() {
  if (!isTrailing) {
    background(palette[4]);
  }
  translate(width / 2, height / 2);
  rotate(frameCount * .01);

  int cycle = 1;
  float prevRadius = 0;
  float prevAngle = 0;
  fft.analyze(spectrum);

  int gamma = 2;
  float smooth = pow(2, 1/frameRate);
  for(int i = bands - 1; i >= 0; i--) {
    float band = spectrum[i];
    displayBands[i] += (band - displayBands[i]) * .1;

    println("band[" + i + "]: " + band + " | smoothed: " + displayBands[i]);
    stroke(lerpColors(displayBands[i] * 3, palette[0],palette[1],palette[2],palette[3]));
    float a = angle(prevAngle, cycle, displayBands[i]);
    float r = radius(a, prevAngle, prevRadius);
    equiTri(0,0, r, a);

    prevAngle = a;
    prevRadius = r;
    if (cycle == 1) {
      prevStartAngle = prevAngle;
    }
    cycle = cycle < maxCycle ? cycle + 1 : 0;
  }
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
  // if (key == 's') {
  //   seed = (int) random(99999);
  //   noiseSeed(seed);
  //   redraw();
  // } else
  if (key == '}') {
    switchPalette(paletteIndex + 1);
  } else if (key == '{') {
    switchPalette(max(0, paletteIndex - 1));
  } else if (key == 'i') {
    String name = String.format("audio-tri-%s.png", millis());
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
  } else if (key == 'r') {
    isRecording = !isRecording;
    if (isRecording) {
      videoExport.setMovieFileName(String.format("audio-tri-%s.mp4", millis()));
      videoExport.startMovie();
    } else {
      videoExport.endMovie();
    }
  } else if (key == 'p') {
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
  // } else if (key == 'b') {
  //   frameRateReset = frameCount;
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

