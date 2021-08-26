import processing.svg.*;
import java.io.File;
import java.util.*;
import com.fasterxml.jackson.annotation.*;
import com.fasterxml.jackson.databind.ObjectMapper;

final String PROJECT_NAME = "border";
final String STATE_FILE = "data.json";
final boolean GENERATE_SVG = false;
int showState = 1;

State state;
float speed = .001;

String getFileName(String ext) {
  return String.format("%s__%s.%s", PROJECT_NAME, System.currentTimeMillis(), ext);
}

void setup() {
  size(7, 4);
  if (GENERATE_SVG) {
    beginRecord(SVG, getFileName("svg"));
  }
  smooth(8);
  noFill();
  background(255);
  strokeWeight(2);
  noLoop();
}

void draw() {
  background(255);

  rect(0, 0, width, height);

  if (GENERATE_SVG) {
    endRecord();
    exit();
  }
}
