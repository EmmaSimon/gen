import processing.svg.*;
import java.io.File;
import java.util.*;
import com.fasterxml.jackson.annotation.*;
import com.fasterxml.jackson.databind.ObjectMapper;

final String PROJECT_NAME = "__TEMPLATE__";
final String STATE_FILE = "data.json";
final boolean GENERATE_SVG = false;
int showState = 1;

State state;
float speed = .001;

String getFileName(String ext) {
  return String.format("%s__%s.%s", PROJECT_NAME, System.currentTimeMillis(), ext);
}

void setup() {
  size(800, 800);
  if (GENERATE_SVG) {
    beginRecord(SVG, getFileName("svg"));
  }
  smooth(8);
  noFill();
  background(255);
  strokeWeight(2);
  noLoop();
  textFont(createFont("OCRA.ttf", 10));
  StateInitializer init = new StateInitializer() {
    HashMap<String, Object> getStateTemplate() {
      return new HashMap<String, Object>(){{
        put("gridSize", 10);
        put("seed", (int) random(99999));
        put("multiplier", 666);
        put("counter", 10);
      }};
    }
  };
  state = State.loadState(new File(sketchPath(), STATE_FILE), init);
  noiseSeed(state.getInt("seed"));
}

float negged(float n) {
  return map(n, 0, 1, -1, 1);
}

void draw() {
  background(255);
  drawState();
  translate(width / 2, height / 2);

  for (int c = 0; c < state.getInt("counter"); c++) {
    circle(0, 0, c * state.getInt("multiplier") / 10);
  }

  if (GENERATE_SVG) {
    endRecord();
    exit();
  }
}

void reset() {
  clear();
  background(255);
  noiseSeed(state.getInt("seed"));
  redraw();
}

Boolean isShifted = false;
Boolean isCtrled = false;
void keyPressed() {
  if (key == 's') {
    state.pushState(
      new HashMap<String, Object>() {{
        put("seed", (int) random(99999));
      }}
    );
    reset();
  } else if (key == 'e') {
    state.erase();
    reset();
  } else if (key == 'p') {
    String name = getFileName("png");
    println(String.format("Saving %s", name));
    save(name);
  } else if (keyCode == LEFT) {
    state.prev();
    reset();
  } else if (keyCode == RIGHT) {
    state.next();
    reset();
  } else if (key == '.') {
    state.set("counter", state.getInt("counter") + 1);
    reset();
  } else if (key == ',') {
    state.set("counter", max(0, state.getInt("counter") - 1));
    reset();
  } else if (key == '>') {
    state.set("multiplier", state.getInt("multiplier") + 1);
    reset();
  } else if (key == '<') {
    state.set("multiplier", max(0, state.getInt("multiplier") - 1));
    reset();
  } else if (key == '~') {
    showState = (showState + 1) % 3;
    reset();
  } else if (keyCode == SHIFT) {
    isShifted = true;
  } else if (keyCode == ALT) {
    isCtrled = true;
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
  } else if (key == '.') {
    state.writeStatus();
  } else if (key == ',') {
    state.writeStatus();
  } else if (key == '>') {
    state.writeStatus();
  } else if (key == '<') {
    state.writeStatus();
  }
}

void drawState() {
  if (GENERATE_SVG || showState < 1) {
    return;
  }
  fill(0);
  int index = state.history.index;
  int endIndex = state.history.entries.size() - 1;
  int fontSize = 10;

  textAlign(LEFT, TOP);
  // textSize(fontSize);
  if (showState > 0) {
    String leftElements = index > 0
      ? String.format("%s%s", 0, index > 1 ? ".." : "")
      : "";
    String rightElements = index < endIndex
      ? String.format("%s%s", index < endIndex - 1 ? ".." : "", endIndex)
      : "";
    String positionInfo = String.format("[%s(%s)%s]", leftElements, index, rightElements);
    text(positionInfo, 2, 2);
  }
  if (showState > 1) {
    String currentState = state.history.getCurrent().toString();
    text(currentState, 2, (int) fontSize + (fontSize/3) + 2);
  }
  noFill();
}
