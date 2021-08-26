/**
 * Hexagonal grid utility class
 * Dependencies: toxiclibs-0018 or newer
 * LGPL2 licensed
 */
import toxi.geom.*;
import toxi.processing.*;

HexGrid grid;
ToxiclibsSupport gfx;


int padding = 10;
int gridWidth = 11;
int gridHeight = 11;

void setup() {
  size(600, 600);


  float hexRadius = width / (gridWidth - .5) / 2;
  grid = new HexGrid(hexRadius, gridWidth, gridHeight);
  gfx = new ToxiclibsSupport(this);
}

void draw() {
  background(255);
  noFill();
  translate(50, 50);
  grid.draw(gfx);
}

public class Hex {
    int in, out, x, y;
    Polygon2D shape;

    private Polygon2D getShape() {
        if (shape != null) {
            return shape;
        }
        return null;
    }

    public Hex() {}
    public Hex(Polygon2D shape, int x, int y) {
        this.shape = shape;
        this.x = x;
        this.y = y;
    }
    public Hex(int in) {
        this.in = in;
    }
    public Hex(int in, int out) {
        this.in = in;
        this.out = out;
    }

    public void setIn(int in) {
        this.in = in;
        Vec2D center = shape.getCentroid();
        shape.vertices.add(in, center);
    }
    public void setOut(int out) {
        this.out = out;
        Vec2D center = shape.getCentroid();
        shape.vertices.add(out, center);
    }
}

public class HexGrid {
  float cellWidth, cellHeight;
  int cols, rows;
  Polygon2D hexProto;
  Hex[][] grid;

  public HexGrid(float radius, int cols, int rows) {
    hexProto = new Circle(radius).toPolygon2D(6);
    int vc = 0;
    for(Vec2D v : hexProto.vertices) {
        /**
            Turn each face PI/6, go from having the flat on the top and bottom, to pointy up and down with flat sides
        */
        v.rotate(PI/6);
    }
    Vec2D center = hexProto.getCentroid();
    println("c:", center);
    for(Vec2D v : hexProto.vertices) {
        float angle = center.angleBetween(v, true);
        println("v: "+v);
        println("aaaaa", angle);
        float dist = center.distanceTo(v);
        println("dist: "+dist);
        v.x += cos(angle) * vc;
        v.y += sin(angle) * vc;
    }


    this.cols = cols;
    this.rows = rows;
    this.grid = new Hex[this.cols][this.rows];
    cellWidth = hexProto.getBounds().width;
    cellHeight = cellWidth * sin(PI/3);
    this.populate();
  }

  private Hex placeHex(int x, int y) {
    Hex hex = new Hex(hexProto.copy(), x, y);
    return hex;
  }

  private Hex[] getSurroundings(int x, int y) {
    Hex[] surroundings = new Hex[6];
    int angle = -1;
    for (int down = -1; down <= 1; down++) {
        for (int across = -1; across < 1; across++) {
            angle++;
            int xPos = x + (down == 0 && across == 0 ? 1 : across) + (y % 2 == 0 && down != 0 ? 1 : 0);
            int yPos = y + down;
            print("angle ", angle, " x ", x, " y ", y, " xPos ", xPos, " yPos ", yPos, "\n");
            if (
                yPos < 0 ||
                yPos > this.rows - 1 ||
                xPos < 0 ||
                xPos > this.cols - (x % 2)
            ) {
                continue;
            }
            surroundings[angle] = grid[xPos][yPos];
        }
    }
    return surroundings;
  }

  void populate() {
    for (int x = 0; x < cols; x++) {
        for (int y = 0; y < rows; y++) {
            if (y % 2 == 0 && x == cols - 1) {
                continue;
            }
            this.grid[x][y] = placeHex(x, y);
        }
    }
  }

  void draw(ToxiclibsSupport gfx) {
    for (int x = 0; x < cols; x++) {
      for (int y = 0; y < rows; y++) {
        if (this.grid[x][y] == null || this.grid[x][y].getShape() == null) {
            continue;
        }
        noFill();
        Vec2D position = getPosForCell(x,y);
        gfx.polygon2D(
            this.grid[x][y].getShape().copy().translate(position)
        );
        gfx.polygon2D(new Circle(2).toPolygon2D(10).copy().translate(position));
        // fill(0, 0, 0);
        // text(String.format("%s, %s", x, y), position.x, position.y);
      }
    }
  }

  Vec2D getPosForCell(int x, int y) {
    return new Vec2D((x + (0 == y % 2 ? 0.5 : 0)) * cellWidth, y * cellHeight);
  }
}
