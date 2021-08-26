float[][] grid;
int left_x, right_x, top_y, bottom_y, resolution, num_columns, num_rows;

void setup() {
  size(350, 200);
  //noStroke();
  smooth();
  noFill();
  strokeWeight(3);

  left_x = int(width * -0.5);
  right_x = int(width * 1.5);
  top_y = int(height * -0.5);
  bottom_y = int(height * 1.5); 
  resolution = int(width * 0.01); 
  num_columns = (right_x - left_x) / resolution;
  num_rows = (bottom_y - top_y) / resolution;

  grid = new float[num_columns][num_rows];
  float default_angle = PI * 0.25;
  for (int column = 0; column < num_columns; column++) {
      for (int row = 0; row < num_rows; row++) {
        float angle = (row / float(num_rows)) * PI;
        grid[column][row] = angle;
      }
  }
}

void curve(int px, int py) {
  vertex(px, py);
  for (int n = 0; n < 50; n++) {
    int x_offset = px - left_x;
    int y_offset = py - top_y;
    int column = min(int(x_offset / resolution), num_columns - 1);
    int row = min(int(y_offset / resolution), num_rows - 1);
    float grid_angle = grid[column][row];
    int x_step = round(10 * cos(grid_angle));
    int y_step = round(10 * sin(grid_angle));
    quadraticVertex(px + x_step, py + y_step, px, py);

    if (px < 0 || px > width || py < 0 || py > height) {
      break;
    }
    
    px = px + x_step;
    py = py + y_step;
  }
  endShape();
}

void draw() {
  background(0); //<>//
  stroke(255);
  strokeWeight(3);
  for (int l = 0; l <= 6; l++) {
    beginShape();
    int px, py;
    px = 0;
    py = l * height/6;
    curve(px, py);
    //line(l * (width/10),0, l*(width/10), height);
  }
  
   for (int l = 1; l <= 10; l++) {
    beginShape();
    int px, py;
    px = l * height/6;
    py = 0;
    curve(px, py);
    //line(l * (width/10),0, l*(width/10), height);
  }
}
