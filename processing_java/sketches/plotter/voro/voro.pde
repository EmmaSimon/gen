import megamu.mesh.*;

import processing.svg.*;
import java.io.File;
import java.util.*;
import com.fasterxml.jackson.annotation.*;
import com.fasterxml.jackson.databind.ObjectMapper;

final String PROJECT_NAME = "voro";
final String STATE_FILE = "data.json";
final boolean GENERATE_SVG = false;
int showState = 1;

State state;
float speed = .001;

String getFileName(String ext) {
  return String.format("%s__%s.%s", PROJECT_NAME, System.currentTimeMillis(), ext);
}

float[][] randPoints(int numPoints) {
  float[][] points = new float[numPoints][2];
  for(int i = 0; i < numPoints; i++) {
    points[i][0] = random(width);
    points[i][1] = random(height);
  }
  return spacePoints(points);
}

float[][] spacePoints(float[][] points) {
  for(int i = 0; i < points.length; i++) {
    for(int j = 0; j < i; j++) {
      int spacing = state.getInt("multiplier");
      int tries = 0;
      while (tries < 100 && dist(points[i][0], points[i][1], points[j][0], points[j][1]) < spacing) {
        points[i][0] = points[i][0] + min(0, max(random(-spacing, spacing), width));
        points[i][1] = points[i][1] + min(0, max(random(-spacing, spacing), height));
        tries++;
      }
    }
  }
  return points;
}

float[][] resizePoints(float[][] points, int size) {
  if (size == points.length) {
    return points;
  } else if (size < points.length) {
    return clonePoints(points, size);
  }
  float[][] morePoints = clonePoints(points, size);
  for(int i = points.length; i < size; i++) {
    morePoints[i][0] = random(width);
    morePoints[i][1] = random(height);
  }
  spacePoints(morePoints);
  return morePoints;
}

float[][] clonePoints(float[][] points, int size) {
  float[][] newPoints = new float[size][2];
  for(int i = 0; i < min(size, points.length); i++)
      newPoints[i] = points[i].clone();
  return newPoints;
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
        put("numPoints", 10);
        put("pointGrid", randPoints(10));
      }};
    }
  };
  state = State.loadState(new File(sketchPath(), STATE_FILE), init);
  noiseSeed(state.getInt("seed"));
}

float negged(float n) {
  return map(n, 0, 1, -1, 1);
}

float[] intersectionPoint(float x1, float y1, float x2, float y2, float x3, float y3, float x4, float y4) {

  // calculate the distance to intersection point
  float uA = ((x4-x3)*(y1-y3) - (y4-y3)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));
  float uB = ((x2-x1)*(y1-y3) - (y2-y1)*(x1-x3)) / ((y4-y3)*(x2-x1) - (x4-x3)*(y2-y1));

  // if uA and uB are between 0-1, lines are colliding
  if (uA >= 0 && uA <= 1 && uB >= 0 && uB <= 1) {

    // optionally, draw a circle where the lines meet
    float intersectionX = x1 + (uA * (x2-x1));
    float intersectionY = y1 + (uA * (y2-y1));
    return new float[] {intersectionX, intersectionY};
  }
  return null;
}

void maxLine(float x1, float y1, float x2, float y2, float xMax, float yMax) {
  if (
    x1 >= 0 && x1 <= xMax &&
    x2 >= 0 && x2 <= xMax &&
    y1 >= 0 && y1 <= yMax &&
    y2 >= 0 && y2 <= yMax
  ) {
    line(x1, y1, x2, y2);
  } else if (
    (x1 < 0 || x1 > xMax || y1 < 0 || y1 > yMax) &&
    (x2 < 0 || x2 > xMax || y2 < 0 || y2 > yMax)
  ) {
    return;
  }

  if (x1 < 0 || x2 < 0) {
    float[] leftIntersect = intersectionPoint(x1, y1, x2, y2, 0, 0, 0, yMax);
    if (leftIntersect != null) {
      if (x1 < x2) {
        x1 = leftIntersect[0];
        y1 = leftIntersect[1];
      } else {
        x2 = leftIntersect[0];
        y2 = leftIntersect[1];
      }
    }
  }
  if (x1 > xMax || x2 > xMax) {
    float[] rightIntersect = intersectionPoint(x1, y1, x2, y2, xMax, 0, xMax, yMax);
    if (rightIntersect != null) {
      if (x1 > x2) {
        x1 = rightIntersect[0];
        y1 = rightIntersect[1];
      } else {
        x2 = rightIntersect[0];
        y2 = rightIntersect[1];
      }
    }
  }
  if (y1 < 0 || y2 < 0) {
    float[] topIntersect = intersectionPoint(x1, y1, x2, y2, 0, 0, xMax, 0);
    if (topIntersect != null) {
      if (y1 < y2) {
        x1 = topIntersect[0];
        y1 = topIntersect[1];
      } else {
        x2 = topIntersect[0];
        y2 = topIntersect[1];
      }
    }
  }
  if (y1 > yMax || y2 > yMax) {
    float[] bottomIntersect = intersectionPoint(x1, y1, x2, y2, 0, yMax, xMax, yMax);
    if (bottomIntersect != null) {
      if (y1 > y2) {
        x1 = bottomIntersect[0];
        y1 = bottomIntersect[1];
      } else {
        x2 = bottomIntersect[0];
        y2 = bottomIntersect[1];
      }
    }
  }
  line(x1, y1, x2, y2);
}

void maxLine(float x1, float y1, float x2, float y2) {
  maxLine(x1, y1, x2, y2, width, height);
}

void draw() {
  background(255);
  drawState();

  float[][] points = state.getPointArray("pointGrid");

  Delaunay dela = new Delaunay(points);
  Voronoi voro = new Voronoi(points);

  float[][] dedges = dela.getEdges();
  for(int i=0; i<dedges.length; i++)
  {
    float startX = dedges[i][0];
    float startY = dedges[i][1];
    float endX = dedges[i][2];
    float endY = dedges[i][3];
    maxLine( startX, startY, endX, endY );
  }
  float[][] vedges = voro.getEdges();
  for(int i=0; i<vedges.length; i++)
  {
    float startX = vedges[i][0];
    float startY = vedges[i][1];
    float endX = vedges[i][2];
    float endY = vedges[i][3];
    maxLine( startX, startY, endX, endY );
  }
  for(int i=0; i<points.length; i++)
  {
    float x = points[i][0];
    float y = points[i][1];
    circle(x, y, state.getInt("multiplier") * noise(x, y) / 2);
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
    state.set("seed", (int) random(99999));
    state.set("pointGrid", randPoints(state.getInt("numPoints")));
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
    state.set("pointGrid", spacePoints(state.getPointArray("pointGrid")));
    reset();
  } else if (key == '<') {
    state.set("multiplier", max(0, state.getInt("multiplier") - 1));
    state.set("pointGrid", spacePoints(state.getPointArray("pointGrid")));
    reset();
  } else if (key == ']') {
    state.set("numPoints", state.getInt("numPoints") + 1);
    state.set("pointGrid", resizePoints(state.getPointArray("pointGrid"), state.getInt("numPoints")));
    reset();
  } else if (key == '[') {
    state.set("numPoints", max(1, state.getInt("numPoints") - 1));
    state.set("pointGrid", resizePoints(state.getPointArray("pointGrid"), state.getInt("numPoints")));
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
  // } else if (key == '.') {
  //   state.writeStatus();
  // } else if (key == ',') {
  //   state.writeStatus();
  // } else if (key == '>') {
  //   state.writeStatus();
  // } else if (key == '<') {
  //   state.writeStatus();
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
