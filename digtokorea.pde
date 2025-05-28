Square[] grid; // grid for all squares on the screen / anything that can be mined
Player player;
int TILE_SIZE; // size for one square
int w, h; // unit is number of squares
float cameraOffset;  

//Time gauging purpose
int currSec;
int currMin;
double totalTime = 30;
double remainingTime = 30;

//Game pause/shop phase
boolean gamePaused = false;
boolean gameStart = false;

// for horizontal movement and digging down
boolean leftPressed;
boolean rightPressed;
boolean downPressed;

//Power up
boolean timeFrozen = false;

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
    //Triggering the start of a game USE SETUP()
    
    //Tracking stopwatch and time remaining in the case of a continuing game
    if (gamePaused == false){
      remainingTime -= (1.0/60); //60 to account for a 60fps game
      if (remainingTime < (0)){
        gamePaused = true;
      }
      if (frameCount % 60 == 0){
        currSec++;
        if (currSec > 60){
          currSec = 0;
          currMin++;
        }
      }
    }
    else{ //Creation of shop
      leftPressed = false;
      downPressed = false;
      rightPressed = false;
      
    }

    
    player.move();
    cameraOffset = player.position.y - height/3;
    
    drawGrid();

    player.draw();
    
    fill(0, 0, 0);
    
    //Main game stopwatch
    textSize(100);
    fill(#000000);
    rect(0,0, (230), (100));
    fill(#00FF00);
    String secondTime = "" + currSec;
    String minTime = "" + currMin;
    if (currSec < 10){
       secondTime = "0" + currSec;
    }
    if (currMin < 10){
       minTime = "0" + currMin;
    }
    text("" + minTime + ":" + secondTime , 0, 80);
    
    //Round timer
    fill(#a8a7a6);
    rect(width/6, height/5, (float)(width * (4.0/6)), 20);
    fill(#e95c50);
    rect(width/(6 - .1), height/(5-.06), (float)(remainingTime / totalTime * (width * (0.661))), 15); //CALCULATED WIDTH BY doing (1 - 2/.59)
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
  if (gamePaused == false){
    if (key == 'a') leftPressed = true;
    if (key == 'd') rightPressed = true;
    if (key == 's') downPressed = true;
  }
}

public void keyReleased() {
  if (gamePaused == false){
    if (key == 'a') leftPressed = false;
    if (key == 'd') rightPressed = false;
    if (key == 's') downPressed = false;
  }
}
