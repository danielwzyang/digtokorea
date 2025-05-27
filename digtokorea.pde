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
final int TITANIUM = 3;

// health for each square by layer
int[] SQUARE_HEALTH = {15, 30, 60};

// sprites
PImage PLAYER_SPRITE, PICKAXE_SPRITE, DIRT_SPRITE, CLAY_SPRITE;
PImage[] COAL_SPRITES, IRON_SPRITES, GOLD_SPRITES;

int[] resources = {0, 0, 0, 0};

public void setup() {
    size(750, 1000);
    
    PLAYER_SPRITE = loadImage("sprites/player.png");
    PICKAXE_SPRITE = loadImage("sprites/pickaxe.png");
    
    DIRT_SPRITE = loadImage("sprites/dirt.png");
    CLAY_SPRITE = loadImage("sprites/clay.png");
    
    COAL_SPRITES = new PImage[]{
        loadImage("sprites/dirt_coal.png"),
        loadImage("sprites/clay_coal.png"),
    };
    
    IRON_SPRITES = new PImage[]{
        loadImage("sprites/dirt_iron.png"),
        loadImage("sprites/clay_iron.png"),
    };
    
    GOLD_SPRITES = new PImage[]{
        loadImage("sprites/dirt_gold.png"),
        loadImage("sprites/clay_gold.png"),
    };

    TILE_SIZE = 30;
    w = 30;
    h = 300;
    
    grid = new Square[w*h];
    setupGrid();
    
    player = new Player();
}

public void setupGrid() {
    dirtLayer();
    clayLayer();
}

public void dirtLayer() {
    // rows of dirt
    for (int i = 0; i < 50 * w; i++) {
        grid[i] = new Dirt();
    }
    
    // coal randomly dispersed
    for (int i = 0; i < 50; i++) {
        grid[int(random(50 * w))] = new Coal(0);
    }
    
    // iron randomly dispersed
    for (int i = 0; i < 30; i++) {
        grid[int(random(50 * w))] = new Iron(0);
    }
    
    // gold randomly dispersed
    for (int i = 0; i < 50; i++) {
        grid[int(random(50 * w))] = new Gold(0);
    }
}

public void clayLayer() {
    // spots of clay in dirt layer with increasing densities
    for (int i = 0; i < 20; i++) {
        grid[int(random(10 * w)) + 40 * w] = new Clay();
    }
    for (int i = 0; i < 20; i++) {
        grid[int(random(5 * w)) + 45 * w] = new Clay();
    }
    for (int i = 0; i < 20; i++) {
        grid[int(random(2 * w)) + 48 * w] = new Clay();
    }
  
    // rows of clay
    for (int i = 50 * w; i < 100 * w; i++) {
        grid[i] = new Clay();
    }
    
    // coal randomly dispersed
    for (int i = 0; i < 50; i++) {
        grid[50 * w + int(random(50 * w))] = new Coal(1);
    }
    
    // iron randomly dispersed
    for (int i = 0; i < 30; i++) {
        grid[50 * w + int(random(50 * w))] = new Iron(1);
    }
    
    // gold randomly dispersed
    for (int i = 0; i < 50; i++) {
        grid[50 * w + int(random(50 * w))] = new Gold(1);
    }
}

public void draw() {
    background(161, 211, 255);
      
    player.move();
    cameraOffset = player.position.y - height/3;
    
    drawGrid();

    player.draw();
    
    fill(0, 0, 0);
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
