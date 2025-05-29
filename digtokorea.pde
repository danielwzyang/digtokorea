Square[] grid; // grid for all squares on the screen / anything that can be mined
Player player;
int TILE_SIZE; // size for one square
int w, h; // unit is number of squares
float cameraOffset;

// Time gauging purpose
int currSec;
int currMin;
double totalTime = 15;
double remainingTime = 15;

// Game pause/shop phase
boolean gamePaused = false;
boolean gameStart = false;
double shopTime = 0;

// Restart game phase
boolean newRoundTrue = true;

// for horizontal movement and digging down
boolean leftPressed;
boolean rightPressed;
boolean downPressed;

// Initial left slide animation
double slide = -1000;
double acceleration = .1;
boolean bounceThreeTimes = true;
int bounceCount = 0;

// Power up
boolean timeFrozen = false;

// resources that the player has
final int COAL = 0;
final int IRON = 1;
final int GOLD = 2;
final int TITANIUM = 3;

// health for each square by layer
int[] SQUARE_HEALTH = { 15, 30, 60 };

// sprites
PImage BANNER_SPRITE, SHOP_SPRITE, PLAYER_SPRITE, PICKAXE_SPRITE, DIRT_SPRITE, CLAY_SPRITE;
PImage[] RESOURCE_SPRITES, COAL_SPRITES, IRON_SPRITES, GOLD_SPRITES;

int[] resources = { 0, 0, 0, 0 };

PFont font;

public void setup() {
    size(750, 1000);

    BANNER_SPRITE = loadImage("sprites/banner.png");
    SHOP_SPRITE = loadImage("sprites/shop.png");
    PLAYER_SPRITE = loadImage("sprites/player.png");
    PICKAXE_SPRITE = loadImage("sprites/pickaxe.png");

    DIRT_SPRITE = loadImage("sprites/dirt.png");
    CLAY_SPRITE = loadImage("sprites/clay.png");
    
    RESOURCE_SPRITES = new PImage[] {
        loadImage("sprites/coal.png"),
        loadImage("sprites/iron.png"),
        loadImage("sprites/gold.png"),
        loadImage("sprites/coal.png"),
    };

    COAL_SPRITES = new PImage[] {
        loadImage("sprites/dirt_coal.png"),
        loadImage("sprites/clay_coal.png"),
    };

    IRON_SPRITES = new PImage[] {
        loadImage("sprites/dirt_iron.png"),
        loadImage("sprites/clay_iron.png"),
    };

    GOLD_SPRITES = new PImage[] {
        loadImage("sprites/dirt_gold.png"),
        loadImage("sprites/clay_gold.png"),
    };

    TILE_SIZE = 30;
    w = 30;
    h = 300;

    grid = new Square[w * h];
    setupGrid();

    player = new Player();

    font = createFont("pixelfont.ttf", 50);
    textFont(font);
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
  
    if (newRoundTrue) {
        grid = new Square[w*h];
        setupGrid();
        player = new Player();
        shopTime = 0;
        remainingTime = totalTime;
        slide = -1000;
        newRoundTrue = false;
        bounceCount = 0;
        bounceThreeTimes = true;
        acceleration = .1;
    }
  
    background(161, 211, 255);
    
    player.move();
    cameraOffset = player.position.y - height/3;
    
    drawGrid();

    player.draw();
    
    fill(0, 0, 0);
    
    // depth banner
    drawBanner();
    
    //Round timer
    drawRoundTimer();
    
    //Tracking stopwatch and time remaining in the case of a continuing game
    if (gamePaused == false){ //DIGGING PHASE
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
        //Main game stopwatch
        drawStopwatch(false);
        
    }
    else{ //SHOP PHASE
        drawStopwatch(true);
        
        //Creation of shop

        leftPressed = false;
        downPressed = false;
        rightPressed = false;
        fill(#e0e0de);
        
        if (slide < 0 && bounceThreeTimes){ //OVERALL POINT IS TO GET THEM 1000 UNITS TO THE RIGHT
            slide += acceleration;
            acceleration += .3;
        }
        if (slide > 0){
            if (acceleration > 0){
                acceleration = 0;
            }
            slide+= acceleration;
            acceleration -= .3;
            if (slide < 0){
                bounceCount++;
            }
            if (bounceCount >= 3){
                bounceThreeTimes = false;
                slide = 0;
            }
        }
        
        drawShop();
        
        if (frameCount % 60 == 0){
            shopTime++;
        }
    }
    
}

public void drawBanner() {
    image(BANNER_SPRITE, 0, 300);
    fill(#ffffff);
    textSize(15);
    text(int((player.position.y + player.size) / TILE_SIZE) + "m", 10, 320);
}

public void drawRoundTimer() {
    fill(#a8a7a6);
    rect(15, 15, 300, 20);
    fill(#e95c50);
    rect(18, 18, (float)(remainingTime / totalTime * 294), 14);
}

public void drawStopwatch(boolean stopped) {
    textSize(40);
    
    if (stopped)
        fill(#0394fc);
    else
        fill(#e95c50);
    
    String secondTime = "" + currSec;
    String minTime = "" + currMin;
    if (currSec < 10){
        secondTime = "0" + currSec;
    }
    if (currMin < 10){
        minTime = "0" + currMin;
    }
    
    text("" + minTime + ":" + secondTime, width-150, 40);
}

public void drawShop() {
    image(SHOP_SPRITE, (float)slide + 60, 350);
    
    // resources
    for (int i = 0; i < resources.length; i++) {
        fill(#000000);
        textSize(20);
        
        float x = (float) slide + 130 + i * 80;
        
        
        image(RESOURCE_SPRITES[i], x - 20, 380);
        text(resources[i], x, 450);
    }
    
    // play again button
    textSize(15);
    fill(#b5c76d);
    rect((float)slide + 450, 600, 150, 30);
    fill(#ffffff);
    text("PLAY AGAIN", (float) slide + 470, 620);
    
    
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

        tint(constrain((int) ((grid[i].health / grid[i].maxHealth) * 255), 175, 255));
        image(grid[i].sprite, col * TILE_SIZE, row * TILE_SIZE - cameraOffset);
    }
}

public void keyPressed() {
    if (gamePaused == false && newRoundTrue == false) {
        if (key == 'a')
            leftPressed = true;
        if (key == 'd')
            rightPressed = true;
        if (key == 's')
            downPressed = true;
    }
}

public void mouseClicked() {
    if (mouseX > 450 && mouseX < 600 && mouseY > 600 && mouseY < 630 && gamePaused && shopTime > 2) {
        newRoundTrue = true;
        gamePaused = false;
    }
}

public void keyReleased() {
    if (gamePaused == false) {
        if (key == 'a')
            leftPressed = false;
        if (key == 'd')
            rightPressed = false;
        if (key == 's')
            downPressed = false;
    }
}
