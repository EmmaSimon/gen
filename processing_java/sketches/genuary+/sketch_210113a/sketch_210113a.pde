import grafica.*;

GPlot plot;
int step = 0;
int stepsPerCycle = 100;
int lastStepTime = 0;
boolean clockwise = true;
float scale = 5;

void setup() {
  size(450, 450);

  lastStepTime = millis();
  plot = new GPlot(this, 25, 25, height, width);
  plot.setMar(0,0,0,0);
  plot.centerAndZoom(.1, 0, 0);
  plot.addLayer("surface", recalculatePoints());
  // plot.centerAndZoom(1, width/2, height/2);
}

void draw() {
  background(150);
  plot.beginDraw();
  plot.drawBox();
  plot.getLayer("surface").drawFilledContour(GPlot.VERTICAL, 0);
  plot.endDraw();

  if (millis() - lastStepTime > 100) {

    lastStepTime = millis();
  }
}

GPointsArray recalculatePoints() {
  // Prepare the second set of points
  int nPoints = stepsPerCycle + 1;
  GPointsArray points = new GPointsArray(nPoints);
  for (int i = 0; i < nPoints; i++) {
    points.add(calculatePoint(i, stepsPerCycle, 0.9*scale));
  }
  return points;
}

GPoint calculatePoint(float i, float n, float rad) {
  float delta = 0.3*cos(TWO_PI*7*i/n);
  float ang = TWO_PI*i/n;
  return new GPoint(rad*(1 + delta)*sin(ang), rad*(1 + delta)*cos(ang));
}
