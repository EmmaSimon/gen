FastNoiseLite n;
PFont font;

int seed = 420;
int lastPressed = 0;
Node root;
Node seeker;
ArrayList<Integer> seedHistory = new ArrayList();
int seedIndex = 0;

enum Dir {
    UP, DOWN, CENTER;
    Dir get(int d) {
        if (d == 1) {
            return DOWN;
        } else if (d == 2) {
            return CENTER;
        } else {
            return UP;
        }
    }
}

class Node {
    float value;
    String letter;

    int depth;
    int step;
    int numDimensions = 3;

    Node previous;
    Node[] dimensions;

    Node(float value, Node previous) {
        this(value);
        this.previous = previous;
        this.depth = previous.depth + 1;
        this.step = previous.step + 1;
        System.out.println(step + " | l: " + letter + " | depth: " + depth);
    }
    Node(float value) {
        this.value = value;
        this.numDimensions = 3;
        dimensions = new Node[this.numDimensions];
        step = 0;
        depth = 0;
    }
    String getLetter() {
        if (letter != null) {
            return letter;
        }
        letter = String.valueOf(
            (char)(floor((lerp(97, 123, norm(value, -1, 1)) + step) % 123))
        );
        return letter;
    }
}

Node resetRoot() {
    root = new Node(n.GetNoise(0, 0));
    loadPath(root, seeker == null ? 0 : seeker.step);
    seeker = root;
    return root;
}

Node loadStep(Node from, boolean next) {
    if (!next) {
        return from.previous;
    }
    int nextStep = from.step + 1;
    Node growingFrom = from;
    int direction = 0;
    int loop = 0;
    do {
        growingFrom = growingFrom.dimensions[direction] == null ? growingFrom : growingFrom.dimensions[direction];
        float dN = n.GetNoise(from.value * 100, growingFrom.value * 100, loop * 100);
        direction = (loop + (floor(map(dN, -1,1, -1, growingFrom.numDimensions + 1)))) % growingFrom.numDimensions;
        System.out.println("At node " + growingFrom.step + " going in direction " + direction + " based on " + dN + " (" + map(dN, -1,1, 0, growingFrom.numDimensions + 1) + " normed)");
        loop++;
    } while (growingFrom.dimensions[direction] != null);
    System.out.println("Loading new node in direction " + direction + " off of " + growingFrom.step + " to " + nextStep + " at depth " + growingFrom.depth);
    float value = n.GetNoise(nextStep, from.value);
    Node nextNode = new Node(value, from);
    growingFrom.dimensions[direction] = nextNode;
    return nextNode;
}

Node loadPath(Node node, int step) {
    if (node.step == step) {
        return node;
    }
    System.out.println("Loading path from " + node.step + " to " + step);
    return loadPath(loadStep(node, node.step < step), step);
}

void setup () {
    //size(750, 750);
    fullScreen();
    seedHistory.add(seed);
    font = createFont("Louis George Cafe.ttf", 10);
    n = new FastNoiseLite(seed);
    n.SetNoiseType(FastNoiseLite.NoiseType.OpenSimplex2S);
    resetRoot();
    noLoop();
}

void letter(Node node) {
    String l = node.getLetter();
    if (l == null) {
        return;
    }
    text(l, 0, 0);
}

void drawDimensions(Node node) {
    if (node.step == root.step) {
        fill(0, 102, 153);
    } else {
        fill(0);
    }
    letter(node);
    System.out.println("iPush s " + node.step);
    pushMatrix();
    for (int d = 0; d < node.numDimensions; d++) {
        Node dNode = node.dimensions[d];
        if (dNode == null) {
            continue;
        }
        System.out.println("pop " + d +" s " + dNode.step);
        popMatrix();
        translate(10 * sin(d*TAU/3), 10 * cos(d*TAU/3));
        drawDimensions(dNode);
        System.out.println("push " + d + " s " + dNode.step);
        pushMatrix();
    }
    popMatrix();
}

void draw() {
    background(250);
    fill(0);
    text(" s: " + seeker.step + " | v: " + seeker.value + " | seed: " + seed, 0, 10);
    translate(width / 2, height / 2);
    drawDimensions(root);
    //for (int i = -4; i <= 4; i++) {
        //int drawOffset = seeker.step + i;
        //if (drawOffset < 0) {
        //    continue;
        //} else if (drawOffset == 0) {
        //} else {
        //    fill(0);
        //}
        // letter(loadPath(seeker, seeker.step));
    //}
}

void keyPressed() {
    int now = millis();
    if (now - lastPressed < Constants.KEY_DELAY) {
        lastPressed = now;
        return;
    }

    if (key == ']') {
        seedIndex++;
        if (seedIndex == seedHistory.size()) {
            seedHistory.add(seed + floor(lerp(-2000, 2000, n.GetNoise(seed, seeker.step))));
        }
        seed = seedHistory.get(seedIndex);
        n.SetSeed(seed);
        System.out.println("new seed: " + seed);
        resetRoot();
        redraw();
    } else if (key == '[') {
        seedIndex = max(0, seedIndex - 1);
        seed = seedHistory.get(seedIndex);
        n.SetSeed(seed);
        System.out.println("prev seed: " + seed);
        resetRoot();
        redraw();
    }

    if (keyCode == RIGHT || key == 'd') {
        seeker = loadPath(seeker, seeker.step + 1);
        redraw();

    } else if (keyCode == LEFT || key == 'a') {
        seeker = loadPath(seeker, max(0, seeker.step - 1));
        redraw();

    }
    lastPressed = now;
}
