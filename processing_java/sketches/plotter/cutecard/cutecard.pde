import com.fasterxml.jackson.annotation.*;
import com.fasterxml.jackson.databind.ObjectMapper;
import java.awt.event.KeyEvent;
import java.io.File;
import java.util.*;
import processing.svg.*;

final String PROJECT_NAME = "cutecard";
final String STATE_FILE = "data.json";
final boolean GENERATE_SVG = false;
int showState = 1;

State state;
float speed = .001;
PShape baseSVG;

String getFileName(String ext) {
  return String.format("%s__%s.%s", PROJECT_NAME, System.currentTimeMillis(), ext);
}

void setup() {
  size(336, 192);
  if (GENERATE_SVG) {
    beginRecord(SVG, getFileName("svg"));
  }
  smooth(8);
  noFill();
  background(255);
  strokeWeight(1);
  baseSVG = loadShape("cutecard__BACK_copy.svg");
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
  if (mousePressed) {
    clip(mouseX - 50, mouseY - 50, 100, 100);
  } else {
    clip(4, 4, width - 8, height - 8);
  }
  if (!GENERATE_SVG) {
    shape(baseSVG, 0, 0, width, height);
  }
  translate(width / 2, height / 2);


  drawRings();
  // drawTwists();

  if (GENERATE_SVG) {
    endRecord();
    exit();
  }
}

void drawTwists() {
  int snipTo = 1;
  int firstIndent = 7;
  for (int c = 0; c < state.getInt("counter"); c++) {
    float r = c * state.getInt("multiplier") / max(state.getInt("scale"), 0.001);
    int x = state.getInt("midpointX");
    int y = state.getInt("midpointY");
    int lineLen = width - 1;
    float segLen = lineLen / state.getInt("segments");
    beginShape();

    for (int s = (c < snipTo ? firstIndent : 0); s < state.getInt("segments"); s++) {

      float n_0 = noise(c * .5, s) * 1;
      float n_1 = noise(c * .5, s + 1) * 1;
      float start_p_x = x + s * segLen;
      float start_p_y = y + r;
      if (s == 0 || c < snipTo) {
        vertex(start_p_x, start_p_y);
      }
      float end_p_x = x + (s + 1) * segLen;
      float end_p_y = y + r;
      println("\n=== c = " + c + ", s = " + s);
      println("(start_p_x, start_p_y) : (", start_p_x + ", " + start_p_y + ")");
      println("(end_p_x, end_p_y) : (", end_p_x + ", " + end_p_y + ")");
      println("--: ");
      boolean even = s % 2 == 0;
      float xScale = .8;
      float yScale = .8;
      float control_1_x = end_p_x + (((even ? 0 : .5) + n_0) * segLen * xScale);
      float control_1_y = end_p_y + ((even ? 1 : -1) * segLen * yScale * ((true ? .5 : 0) + n_1));
      float control_2_x = start_p_x - (segLen * xScale * ((even ? .5 : 0) + n_1));
      float control_2_y = start_p_y + ((even ? 1 : -1) * segLen * yScale * ((false ? 0 : .5) + n_0));
      println("(control_1_x, control_1_y): (", control_1_x + ", " + control_1_y + ")");
      println("(control_2_x, control_2_y): (", control_2_x + ", " + control_2_y + ")");
      // float cx1 = x + (s * segLen) + (segLen/3);
      // float cy1 = y + r - n;
      // float cx2 = x + (s * segLen) + ((2*segLen)/3);
      // float cy2 = cy1;
      // bezier(x + (s * segLen), y + r, cx1, cy1, cx2, cy2, x + ((s + 1) * segLen), y + r);
      // circle(x + (s * segLen), y + r, 10);
      // circle(control_1_x, control_1_y, 5);
      // circle(control_2_x, control_2_y, 5);
      // line(start_p_x, start_p_y, control_1_x, control_1_y);
      // line(end_p_x, end_p_y, control_2_x, control_2_y);

      bezierVertex(
        control_1_x,
        control_1_y,
        control_2_x,
        control_2_y,
        end_p_x,
        end_p_y
      );
      // circle(x + ((s + 1) * segLen), y + r, 10);
    }
    endShape();
    // line(x, y + r, x + width - 1, y + r);
  }
}

void drawRings() {
  for (int c = 0; c < state.getInt("counter"); c++) {
    float r = c * state.getInt("multiplier") / max(state.getInt("scale"), 0.001);
    if (r > 2 * sqrt(sq(width) + sq(height))) {
      break;
    }
    int x = state.getInt("midpointX");
    int y = state.getInt("midpointY");
    circle(x, y, r);
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
  if (key == '.') {
    state.set("counter", state.getInt("counter") + 1);
    reset();
  }
  if (key == ',') {
    state.set("counter", max(0, state.getInt("counter") - 1));
    reset();
  }
  if (key == '>') {
    state.set("multiplier", state.getInt("multiplier") + 1);
    reset();
  }
  if (key == '<') {
    state.set("multiplier", max(0, state.getInt("multiplier") - 1));
    reset();
  }
  if (key == ']') {
    state.set("scale", state.getInt("scale") + 1);
    reset();
  }
  if (key == '[') {
    state.set("scale", max(0, state.getInt("scale") - 1));
    reset();
  }
  if (key == '}') {
    state.set("segments", state.getInt("segments") + 1);
    reset();
  }
  if (key == '{') {
    state.set("segments", max(0, state.getInt("segments") - 1));
    reset();
  }
  if (key == 'w') {
    state.set("midpointY", state.getInt("midpointY") - 1);
    reset();
  }
  if (key == 'a') {
    state.set("midpointX", state.getInt("midpointX") - 1);
    reset();
  }
  if (key == 's') {
    state.set("midpointY", state.getInt("midpointY") + 1);
    reset();
  }
  if (key == 'd') {
    state.set("midpointX", state.getInt("midpointX") + 1);
    reset();
  }
  if (key == '?') {
    state.pushState(
      new HashMap<String, Object>() {{
        put("seed", (int) random(99999));
      }}
    );
    reset();
  }
  if (keyCode == KeyEvent.VK_BACK_SPACE) {
    state.erase();
    reset();
  }
  if (key == 'p') {
    String name = getFileName("png");
    println(String.format("Saving %s", name));
    save(name);
  }
  if (keyCode == LEFT) {
    state.prev();
    reset();
  } else if (keyCode == RIGHT) {
    state.next();
    reset();
  }
  if (key == '~') {
    showState = (showState + 1) % 3;
    reset();
  }
  if (keyCode == SHIFT) {
    isShifted = true;
  }
  if (keyCode == ALT) {
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
  }
  state.writeStatus();
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
