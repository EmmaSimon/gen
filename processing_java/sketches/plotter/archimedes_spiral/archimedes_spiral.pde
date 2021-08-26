import de.ixdhof.hershey.*;

import processing.svg.*;
import java.io.File;
import java.util.*;
import com.fasterxml.jackson.annotation.*;
import com.fasterxml.jackson.databind.ObjectMapper;

final String PROJECT_NAME = "arch_spiral";
final String STATE_FILE = "data.json";
final boolean GENERATE_SVG = false;
int showState = 1;

PFont kabel;
PFont ocra;
PFont mach;
HersheyFont hf;

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
  kabel = createFont("Kabel Light.otf", 60);
  mach = createFont("MACHTSCR.TTF", 60);
  ocra = createFont("OCRA.ttf", 10);
  hf = new HersheyFont(this, "astrology.jhf");
  hf.textSize(300);

  smooth(8);
  noFill();
  background(255);
  strokeWeight(2);
  noLoop();
  StateInitializer init = new StateInitializer() {
    HashMap<String, Object> getStateTemplate() {
      return new HashMap<String, Object>(){{
        put("seed", (int) random(99999));
        put("iterations", 10);
        put("angleStep", (float) .1f);
        put("skipFirst", 0);
        put("multiplier", 666);
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

  float theta = .5;
  for (int c = 0; c < state.getInt("iterations") + state.getInt("skipFirst"); c++) {

    theta += state.getFloat("angleStep");
    if (c < state.getInt("skipFirst")) {
      continue;
    }
    push();
    rotate(theta/PI);
    // point(theta, 0);
    // circle(theta * state.getInt("multiplier") * .1 + negged(noise(c, c/theta)) * 10, 0, 50);
    hf.text("!", 200 + round(theta * state.getInt("multiplier") * .1), 0);
    pop();
    // System.out.println(theta);
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
    state.set("iterations", state.getInt("iterations") + 1);
    reset();
  } else if (key == ',') {
    state.set("iterations", max(0, state.getInt("iterations") - 1));
    reset();
  } else if (key == '>') {
    state.set("angleStep", state.getFloat("angleStep") + .1f);
    reset();
  } else if (key == '<') {
    state.set("angleStep", max(0, state.getFloat("angleStep") - .1f));
    reset();
  } else if (key == ']') {
    state.set("multiplier", state.getInt("multiplier") + 1);
    reset();
  } else if (key == '[') {
    state.set("multiplier", max(0, state.getInt("multiplier") - 1));
    reset();
  } else if (key == '}') {
    state.set("skipFirst", state.getInt("skipFirst") + 1);
    reset();
  } else if (key == '{') {
    state.set("skipFirst", max(0, state.getInt("skipFirst") - 1));
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
  textFont(ocra);
  fill(0);
  int index = state.history.index;
  int endIndex = state.history.entries.size() - 1;
  int fontSize = 10;

  textAlign(LEFT, TOP);
  textSize(fontSize);
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
