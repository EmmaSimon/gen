import com.cage.colorharmony.ColorHarmony;
import nice.palettes.*;
import com.hamoid.*;

VideoExport videoExport;
FastNoiseLite n;
PFont font;
ColorHarmony colorHarmony;
ColorPalette paletteGen;


class Node {
    int id;
    int depth;
    int branchNumber;
    int numBranches;

    Node parent;
    Node[] branches;

    Node(Node parent, int branchNumber) {
        this.parent = parent;
        this.depth = parent.depth + 1;
        this.branchNumber = branchNumber;
        this.id = nodeId++;
        this.initBranches();
    }
    Node() {
        this.depth = 0;
        this.id = nodeId++;
        this.initBranches();
    }

    void initBranches() {
      this.numBranches = constrain(floor(map(this.getValue(), -1, 1, 3, 6)), 3, 5);
      this.branches = new Node[this.numBranches];
    }

    float getValue() {
      return n.GetNoise(
        (100 * 1/(depth + 1)) + id * 1000 * branchNumber,
        displayFrame * .2
      );
    }

}

Node treeRoot;

int lastPressed = 0;

int seed = -21103;
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

int maxBranches = 5;
float yRot = 0;
int frameOffset = 0;
int displayFrame = 0;
int nodeId = 0;

boolean isPaused = false;
boolean isFramePaused = false;
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

Node buildTree(Node root, int branchBy) {
  if (branchBy == 0) {
    return root;
  }
  root.branches = new Node[root.numBranches];
  float v = root.getValue();
  for (int i = 0; i < root.numBranches; i++) {
    root.branches[i] = new Node(root, i);
    buildTree(root.branches[i], branchBy - 1);
  }
  return root;
}

Node newTree() {
  nodeId = 0;
  Node root = new Node();
  buildTree(root, maxBranches);
  return root;
}

void setup () {
  // size(1080, 1920);
  size(750,750, P3D);
  // fullScreen();
  seedHistory.add(seed);
  n = new FastNoiseLite(seed);
  n.SetNoiseType(FastNoiseLite.NoiseType.OpenSimplex2S);
  colorHarmony = new ColorHarmony(this);
  paletteGen = new ColorPalette(this);
  switchPalette(0);
  strokeWeight(3);
  noFill();
  if (isPaused) {
    noLoop();
  }
  videoExport = new VideoExport(this);
  treeRoot = newTree();
}

void draw() {
  displayFrame = isFramePaused ? displayFrame : frameCount - frameOffset;
  background(palette[0]);
  translate(width/2, height, -300);
  rotateY(frameCount * .01);
  // translate(0, 0, -100);
  // line(0, 0, 0, -10);
  drawTree(treeRoot);
  if (isRecording) {
    videoExport.saveFrame();
  }
}

void drawTree(Node node) {
  float v = node.getValue();
  if (node.depth * (n.GetNoise(displayFrame * .00000000000000001, node.id) + 1) > 5) {
    return;
  }
  float angle = map(v, -1, 1, PI, 0);
  float branchLength =  height / (maxBranches + 1);
  float x = branchLength * cos(angle);
  float y = -branchLength * sin(angle);
  float z = 0;
  float colorRatio = (float) node.depth / (float) maxBranches;
  stroke(lerpColors(colorRatio, palette[1], palette[2], palette[3], palette[4]));
  rotateY(angle);
  line(0, 0, 0, x, y, z);
  pushMatrix();
  translate(x, y);
  for (int c = 0; c < node.numBranches; c++) {
    if (node.branches[c] == null) {
      continue;
    }
    drawTree(node.branches[c]);
  }

  popMatrix();
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

  if (key == ']') {
      seedIndex++;
      if (seedIndex == seedHistory.size()) {
          seedHistory.add(seed + floor(lerp(-2000, 2000, n.GetNoise(lastPressed, seed))));
      }
      seed = seedHistory.get(seedIndex);
      n.SetSeed(seed);
      frameOffset = frameCount;
      System.out.println("new seed: " + seed);
      buildTree(treeRoot, maxBranches);
      redraw();
  } else if (key == '[') {
      seedIndex = max(0, seedIndex - 1);
      seed = seedHistory.get(seedIndex);
      n.SetSeed(seed);
      frameOffset = frameCount;
      System.out.println("prev seed: " + seed);
      buildTree(treeRoot, maxBranches);
      redraw();
  } else if (key == '}') {
    switchPalette(paletteIndex + 1);
  } else if (key == '{') {
    switchPalette(max(0, paletteIndex - 1));
  } else if (key == 'n') {
    noiseTypeIndex = (noiseTypeIndex + 1) % noiseTypes.length;
    switchNoise(noiseTypeIndex);
    buildTree(treeRoot, maxBranches);
  } else if (key == 'N') {
    noiseTypeIndex = noiseTypeIndex == 0 ? noiseTypes.length - 1 : noiseTypeIndex - 1;
    switchNoise(noiseTypeIndex);
    buildTree(treeRoot, maxBranches);
  } else if (key == 'm') {
    fractalTypeIndex = (fractalTypeIndex + 1) % fractalTypes.length;
    switchFractal(fractalTypeIndex);
    buildTree(treeRoot, maxBranches);
  } else if (key == 'M') {
    fractalTypeIndex = fractalTypeIndex == 0 ? fractalTypes.length - 1 : fractalTypeIndex - 1;
    switchFractal(fractalTypeIndex);
    buildTree(treeRoot, maxBranches);
  } else if (key == 'b') {
    frameOffset = frameCount;
  } else if (key == 'p') {
    isFramePaused = !isFramePaused;
    if (isFramePaused) {
      frameOffset =+ displayFrame;
    }
  } else if (key == 'P') {
    isPaused = !isPaused;
    if (isPaused) {
      println("noloop");
      noLoop();
    } else {
      loop();
    }
  } else if (key == 'r') {
    isRecording = !isRecording;
    if (isRecording) {
      videoExport.setMovieFileName(String.format("tree-%s-%s.mp4", seed, millis()));
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
    maxBranches++;
    buildTree(treeRoot, maxBranches);
  } else if (keyCode == DOWN || key == 's') {
    maxBranches = max(1, maxBranches - 1);
    buildTree(treeRoot, maxBranches);
  } else if (keyCode == RIGHT || key == 'd') {
    yRot += .1;
  } else if (keyCode == LEFT || key == 'a') {
    yRot -= .1;
  }
  lastPressed = now;
}
