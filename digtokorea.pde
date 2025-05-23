Square[] grid; // grid for all squares on the screen / anything that can be mined
Player player;
int TILE_SIZE; // size for one square
int w, h; // unit is number of squares
float cameraOffset;  

// for horizontal movement and digging down
boolean leftPressed;
boolean rightPressed;
boolean downPressed;

// resources that the player has
final int COAL = 0;
final int IRON = 1;
final int GOLD = 2;
final int DIAMOND = 3;

// sprites
PImage DIRT_SPRITE;
PImage COAL_SPRITE;

int[] resources = {0, 0, 0, 0};

public void setup() {
    size(750, 1000);
    
    DIRT_SPRITE = loadImage("dirt.png");
    COAL_SPRITE = loadImage("coal.png");

    TILE_SIZE = 25;
    w = 30;
    h = 300;
    
    grid = new Square[w*h];
    setupGrid();
    
    player = new Player();
}

public void setupGrid() {
    dirtLayer();
}

public void dirtLayer() {
    // rows of dirt
    for (int i = 0; i < 20 * w; i++) {
        grid[i] = new Dirt();
    }
    
    // coal randomly dispersed
    for (int coal = 0; coal < 10; coal++) {
        grid[5 * w + int(random(10 * w))] = new Coal();
    }
}

public void draw() {
    background(161, 211, 255);
      
    player.move();
    cameraOffset = player.position.y - height/3;
    
    drawGrid();

    player.draw();
    
    fill(0, 0, 0);

    textSize(30);
    text("coal: " + resources[COAL], 30, 30);
}

public void drawGrid() {
    for (int i = 0; i < grid.length; i++) {
        int row = i / w;
        int col = i % w;
      
        if (grid[i] == null) {
            fill(130, 114, 105);
            square(col * TILE_SIZE, row * TILE_SIZE - cameraOffset, TILE_SIZE);
            continue;
        }
        
        tint(constrain((int)((grid[i].health / grid[i].maxHealth) * 255), 175, 255));
        image(grid[i].getSprite(), col * TILE_SIZE, row * TILE_SIZE - cameraOffset);
    }
}

public void keyPressed() {
    if (key == 'a') leftPressed = true;
    if (key == 'd') rightPressed = true;
    if (key == 's') downPressed = true;
}

public void keyReleased() {
    if (key == 'a') leftPressed = false;
    if (key == 'd') rightPressed = false;
    if (key == 's') downPressed = false;
}
