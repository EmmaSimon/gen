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
int rotations = 6;
int historyIndex;
String HISTORY_FILE = "data.json";
boolean generateSVG = false;


void setup() {
  //fullScreen();
  size(777, 777);
  if (generateSVG) {
    beginRecord(SVG, String.format("circlerotation_%s-%s_%s-%s-%s.svg", month(), day(), hour(), minute(), second()));
  }
  smooth(8);
  noFill();
  background(255);
  strokeWeight(2);
  noLoop();

  initHistory();
}

void draw() {
  translate(width / 2, height / 2);
  background(255);
  stroke(0);
  float circleWidth = 20;
  float circleSpacing = circleWidth;
  float layers = 11;
  float offset = circleWidth / 2;
  for (int l = 1; l < layers - 1; l++) {
    for (int c = 0; c < clones; c++) {
      //float yPos = y * circleSpacing;
      //float jitter = (noise(xPos * .5, yPos * .5) - .5) * 10;
      //float jitter = pow(x, 2) * pow(y, 2) * .009;
      //float jitter = cos(x * y) * 10;
      // float jitter = sin(exp(x) * exp(y)) * 22;
      //float jitter = tan(TAU / (y+.1)) * tan(TAU / (x+.1)) * -34;
      float jitter = (69*noise(l))*(c+1);
      for (int r = 0; r < rotations; r++) {
        // println("l: " + l + " r: " + r + " c:" + c);
        rotate(TAU/rotations);
        push();
        translate(jitter, l * circleSpacing);
        circle(0, 0, circleWidth);
        pop();
      }
      //circle(xPos + jitter, yPos + jitter, circleWidth);
      //circle(xPos + offset + jitter, yPos + offset + jitter, circleWidth);
      //circle(-xPos - jitter, -yPos - jitter, circleWidth);
      //circle(-xPos - offset - jitter, -yPos - offset - jitter, circleWidth);
      //circle(-xPos - jitter, yPos + jitter, circleWidth);
      //circle(-xPos - offset - jitter, yPos + offset + jitter, circleWidth);
      //circle(xPos + jitter, -yPos - jitter, circleWidth);
      //circle(xPos + offset + jitter, -yPos - offset - jitter, circleWidth);
    }
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
    String name = String.format("circlerotation-%s-%s.png", historyIndex, millis());
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
