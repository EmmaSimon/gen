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
int multiplier = 6;
int rotationMultiplier = 1;
int rowCount = 11;
int historyIndex;
String HISTORY_FILE = "data.json";
boolean generateSVG = false;


void setup() {
  //fullScreen();
  size(777, 777);
  if (generateSVG) {
    beginRecord(SVG, String.format("linemail_%s-%s_%s-%s-%s.svg", month(), day(), hour(), minute(), second()));
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
  float lineLength = 20;
  float lineSpacing = lineLength;
  float gridWidth = rowCount;
  float gridHeight = gridWidth;
  float offset = lineLength / 2;
  for (int x = 0; x < gridWidth; x++) {
    for (int y = 0; y < gridHeight; y++) {
      float xPos = x * lineSpacing;
      float yPos = y * lineSpacing;
      // float jitter = 0;
      // float jitter = (noise(xPos * .5, yPos * .5) - .5) * 10;
      // float jitter = pow(x, 2) * pow(y, 2) * .009;
      //float jitter = cos(x * y) * 10;
      float jitter = sin(exp(x) * exp(y)) * multiplier * noise(x*y);
      // float jitter = tan(TAU / (y+.1)) * tan(TAU / (x+.1)) * (multiplier * noise(x*y, x*y));
      // float jitter = (x * y * noise(x,y))/3;

      if (
        abs(xPos + jitter) > ((width/2) - lineSpacing) ||
        abs(yPos + jitter) > ((height/2) - lineSpacing)
      ) {
        continue;
      }

      // float angle = noise(x/(y+1), y/(x+1)) * 1.3;
      float angle;
      if (x > y) {
        angle = (TAU/4) - (TAU * x * rotationMultiplier)/666;
        // angle -= noise(x*y) * (rotationMultiplier);
      } else if (y > x) {
        angle = (TAU * y * rotationMultiplier)/666;
        // angle += noise(x*y) * (rotationMultiplier);
      } else {
        angle = TAU/8;
        // continue;
      }

      if (x % 3 == 0) {
        stroke(255, 0, 0);
      } else if (x % 2 == 1) {
        stroke(0, 255, 0);
      } else {
        stroke(0, 0, 255);
      }
      // float angle = (TAU*x)/666;
      float jitterLength = pow(noise(x*y), 2) * 3 * lineLength;
      // float jitterLength = lineLength;
      float posX = xPos + jitter;
      float posY = yPos + jitter;
      float negX = -xPos - jitter;
      float negY = -yPos - jitter;
      float distX = sin(angle) * jitterLength;
      float distY = cos(angle) * jitterLength;
      line(posX, posY, posX + distX, posY + distY);
      line(negX, negY, negX - distX, negY - distY);
      line(negX, posY, negX - distX, posY + distY);
      line(posX, negY, posX + distX, negY - distY);
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
  rowCount = getHistoryInt("rowCount", loaded);
  multiplier = getHistoryInt("multiplier", loaded);
  rotationMultiplier = getHistoryInt("rotationMultiplier", loaded);
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
    if (historyKey.equals("rowCount")) {
      return rowCount;
    } else if (historyKey.equals("multiplier")) {
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
  println("history length: " + (history.size() - 1));
  historyIndex = min(loaded.getInt("historyIndex"), history.size() - 1);
  println("loading " + historyIndex);
  if (loaded.getInt("historyIndex") != historyIndex) {
    loaded.setInt("historyIndex", historyIndex);
    writeHistory(loaded);
  }
  noiseSeed(getHistoryInt("seed", loaded, historyIndex));
  rowCount = getHistoryInt("rowCount", loaded, historyIndex);
  multiplier = getHistoryInt("multiplier", loaded, historyIndex);
  rotationMultiplier = getHistoryInt("rotationMultiplier", loaded, historyIndex);
}

void writeHistory(JSONObject data) {
  saveJSONObject(data, HISTORY_FILE, "indent=2");
}

void addSeed() {
  JSONObject loaded = loadJSONObject(HISTORY_FILE);
  JSONObject nextState = new JSONObject();
  int newSeed = (int) random(99999);
  nextState.setInt("seed", newSeed);
  nextState.setInt("rowCount", rowCount);
  nextState.setInt("multiplier", multiplier);
  nextState.setInt("rotationMultiplier", rotationMultiplier);

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
    String name = String.format("linemail-%s-%s.png", historyIndex, millis());
    println(String.format("Saving %s", name));
    save(name);
  } else if (keyCode == LEFT) {
    goBackInHistory();
  } else if (keyCode == RIGHT) {
    goForwardInHistory();
  } else if (key == '>' && isShifted) {
    rotationMultiplier += 1;
    setHistoryInt("rotationMultiplier", rotationMultiplier);
    reset();
  } else if (key == '<' && isShifted) {
    rotationMultiplier = max(1, rotationMultiplier - 1);
    setHistoryInt("rotationMultiplier", rotationMultiplier);
    reset();
  } else if (key == '.') {
    setHistoryInt("multiplier", ++multiplier);
    reset();
  } else if (key == ',') {
    multiplier = max(1, multiplier - 1);
    setHistoryInt("multiplier", multiplier);
    reset();
  } else if (keyCode == UP) {
    setHistoryInt("rowCount", ++rowCount);
    reset();
  } else if (keyCode == DOWN) {
    rowCount = max(2, rowCount - 1);
    setHistoryInt("rowCount", rowCount);
    reset();
  } else if (keyCode == SHIFT) {
    isShifted = true;
  } else if (keyCode == ALT) {
    isCtrled = true;
  } else if (key == 'f') {
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
    isLeft = false;
  } else if (keyCode == RIGHT) {
    isRight = false;
  } else if (keyCode == UP) {
    isUp = false;
  } else if (keyCode == DOWN) {
    isDown = false;
  }
}
