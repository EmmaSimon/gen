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
float prevStartAngle = 0;
int clones = 3;
int layers = 11;
int rotations = 6;
int multiplier = 69;
int historyIndex;
String HISTORY_FILE = "data.json";
boolean generateSVG = false;


void setup() {
  //fullScreen();
  size(777, 777);
  if (generateSVG) {
    beginRecord(SVG, String.format("concentric_circles_%s_circ_%s_spacing.svg", layers, multiplier));
  }
  smooth(8);
  noFill();
  background(255);
  strokeWeight(2);
  noLoop();

  initHistory();
}

float mn(float n) {
  return map(n, 0, 1, -1, 1);
}

void draw() {
  translate(width / 2, height / 2);
  background(255);
  stroke(0);
  float circleWidth = 20;
  float circleSpacing = circleWidth;
  float offset = circleWidth / 2;
  float m = multiplier/2;
  for (int l = 1; l < layers; l++) {
    circle(0,0, l*multiplier);
  }

  if (generateSVG) {
    endRecord();
    exit();
  }
}

void goBackInHistory() {
  loadHistoryIndex(max(0, historyIndex - 1));
}

void goForwardInHistory() {
  loadHistoryIndex(historyIndex + 1);
}

void loadHistoryIndex(int loadIndex) {
  JSONObject loaded = loadJSONObject(HISTORY_FILE);
  JSONArray history = loaded.getJSONArray("history");
  historyIndex = loadIndex;
  if (historyIndex >= history.size()) {
    println("loading new history " + historyIndex);
    addSeed();
    return;
  }
  println("loading history " + historyIndex);
  JSONObject historyEntry = history.getJSONObject(historyIndex);
  println(historyEntry);
  loaded.setInt("historyIndex", historyIndex);
  writeHistory(loaded);
  noiseSeed(getHistoryInt("seed", loaded, historyIndex));
  rotations = getHistoryInt("rotations", loaded);
  clones = getHistoryInt("clones", loaded);
  layers = getHistoryInt("layers", loaded);
  multiplier = getHistoryInt("multiplier", loaded);
  reset();
}

void setHistory(JSONObject historyEntry) {
  noiseSeed(historyEntry.getInt("seed"));
}

int getHistoryInt(String historyKey) {
  JSONObject loaded = loadJSONObject(HISTORY_FILE);
  return getHistoryInt(historyKey, loaded);
}

int getHistoryInt(String historyKey, JSONObject state) {
  return getHistoryInt(historyKey, state, state.getInt("historyIndex"));
}

int getHistoryInt(String historyKey, JSONObject state, int index) {
  JSONArray history = state.getJSONArray("history");
  JSONObject historyEntry = history.getJSONObject(index);
  try {
    return historyEntry.getInt(historyKey);
  } catch (RuntimeException e) {
    if (historyKey.equals("rotations")) {
      return 6;
    } else if (historyKey.equals("clones")) {
      return 3;
    }
    return 1;
  }
}


JSONObject setHistoryInt(String historyKey, int value) {
  JSONObject loaded = loadJSONObject(HISTORY_FILE);
  return setHistoryInt(historyKey, value, loaded);
}

JSONObject setHistoryInt(String historyKey, int value, JSONObject state) {
  return setHistoryInt(historyKey, value, state, state.getInt("historyIndex"));
}

JSONObject setHistoryInt(String historyKey, int value, JSONObject state, int index) {
  JSONArray history = state.getJSONArray("history");
  JSONObject historyEntry = history.getJSONObject(index);
  historyEntry.setInt(historyKey, value);
  writeHistory(state);
  return state;
}

void eraseHistoryIndex(int eraseIndex) {
  JSONObject loaded = loadJSONObject(HISTORY_FILE);
  JSONArray history = loaded.getJSONArray("history");
  historyIndex = loaded.getInt("historyIndex");
  if (eraseIndex == 0 && history.size() == 1) {
    println("bro you can't delete everything chill");
    return;
  }

  JSONObject erased = history.getJSONObject(eraseIndex);
  // println("erasing index:" + historyIndex + " seed:"+erased.getInt("seed"));
  history.remove(eraseIndex);
  writeHistory(loaded);
  if (eraseIndex == historyIndex) {
    loadHistoryIndex(min(historyIndex, history.size() - 1));
  }
}

void initHistory() {
  JSONObject loaded = loadJSONObject(HISTORY_FILE);
  JSONArray history = loaded.getJSONArray("history");
  println(history.size() - 1);
  historyIndex = min(loaded.getInt("historyIndex"), history.size() - 1);
  if (loaded.getInt("historyIndex") != historyIndex) {
    loaded.setInt("historyIndex", historyIndex);
    writeHistory(loaded);
  }
  noiseSeed(getHistoryInt("seed", loaded, historyIndex));
  rotations = getHistoryInt("rotations", loaded, historyIndex);
  clones = getHistoryInt("clones", loaded, historyIndex);
  layers = getHistoryInt("layers", loaded, historyIndex);
  multiplier = getHistoryInt("multiplier", loaded, historyIndex);
}

void writeHistory(JSONObject data) {
  saveJSONObject(data, HISTORY_FILE, "indent=2");
}

void addSeed() {
  JSONObject loaded = loadJSONObject(HISTORY_FILE);
  JSONObject nextState = new JSONObject();
  int newSeed = (int) random(99999);
  nextState.setInt("seed", newSeed);
  nextState.setInt("clones", clones);
  nextState.setInt("layers", layers);
  nextState.setInt("multiplier", multiplier);
  nextState.setInt("rotations", rotations);

  JSONArray history = loaded.getJSONArray("history");
  history.append(nextState);
  historyIndex = history.size() - 1;
  loaded.setInt("historyIndex", historyIndex);

  println("new seed:" + newSeed + " i:" + historyIndex);
  writeHistory(loaded);
  loadHistoryIndex(historyIndex);
}

void reset() {
  background(255);
  clear();
  redraw();
}

void keyPressed() {
  if (key == 's') {
    addSeed();
  } else if (key == 'e') {
    eraseHistoryIndex(historyIndex);
  } else if (key == 'i') {
    String name = String.format("concentric_circles-%s-%s.png", historyIndex, millis());
    println(String.format("Saving %s", name));
    save(name);
  } else if (keyCode == LEFT) {
    goBackInHistory();
  } else if (keyCode == RIGHT) {
    goForwardInHistory();
  } else if (key == '.') {
    setHistoryInt("clones", ++clones);
    reset();
  } else if (key == ',') {
    clones = max(1, clones - 1);
    setHistoryInt("clones", clones);
    reset();
  } else if (key == ']') {
    setHistoryInt("layers", ++layers);
    reset();
  } else if (key == '[') {
    layers = max(1, layers - 1);
    setHistoryInt("layers", layers);
    reset();
  } else if (key == '>') {
    setHistoryInt("multiplier", ++multiplier);
    reset();
  } else if (key == '<') {
    multiplier = max(1, multiplier - 1);
    setHistoryInt("multiplier", multiplier);
    reset();
  } else if (keyCode == UP) {
    setHistoryInt("rotations", ++rotations);
    reset();
  } else if (keyCode == DOWN) {
    rotations = max(2, rotations - 1);
    setHistoryInt("rotations", rotations);
    reset();
  } else if (keyCode == SHIFT) {
    isShifted = true;
  } else if (keyCode == ALT) {
    isCtrled = true;
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

  } else if (keyCode == RIGHT) {

  } else if (keyCode == UP) {
  } else if (keyCode == DOWN) {
  }
}
