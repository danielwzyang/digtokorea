Square[] grid; // grid for all squares on the screen / anything that can be mined
Player player;
int TILE_SIZE; // size for one square
int w, h; // unit is number of squares
float cameraOffset;

// Time gauging purpose
int currSec;
int currMin;
double maxTime;
double remainingTime;

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
int[] SQUARE_HEALTH = { 20, 40, 80 };

// sprites

PImage BANNER_SPRITE, RECORD_BANNER_SPRITE, SHOP_SPRITE, PLAYER_SPRITE, PICKAXE_SPRITE, DIRT_SPRITE, CLAY_SPRITE;
PImage[] UPGRADE_SPRITES, RESOURCE_SPRITES, CLOCK_SPRITES, COAL_SPRITES, IRON_SPRITES, GOLD_SPRITES, TITANIUM_SPRITES;

int[] resources = { 0, 0, 0, 0 };

int[] MINING_SPEEDS = { 1, 2, 3, 4, 5 };
int miningIndex = 0;

//Max depth for record keeping
int record;
int currDepth = int((player.position.y + player.size) / TILE_SIZE);

Upgrade[] upgrades;

public void setup() {
    size(750, 1000);

    BANNER_SPRITE = loadImage("sprites/banner.png");
    RECORD_BANNER_SPRITE = loadImage("sprites/record_banner.png");
    SHOP_SPRITE = loadImage("sprites/shop.png");
    PLAYER_SPRITE = loadImage("sprites/player.png");
    PICKAXE_SPRITE = loadImage("sprites/pickaxe.png");

    DIRT_SPRITE = loadImage("sprites/dirt.png");
    CLAY_SPRITE = loadImage("sprites/clay.png");
    
    RESOURCE_SPRITES = new PImage[] {
        loadImage("sprites/coal.png"),
        loadImage("sprites/iron.png"),
        loadImage("sprites/gold.png"),
        loadImage("sprites/titanium.png"),
    };
    
    CLOCK_SPRITES = new PImage[] {
        loadImage("sprites/dirt_clock.png"),
        loadImage("sprites/clay_clock.png"),
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
    
    TITANIUM_SPRITES = new PImage[] {
        null,
        loadImage("sprites/clay_titanium.png"),
    };

    TILE_SIZE = 30;
    w = 30;
    h = 300;

    grid = new Square[w * h];
    setupGrid();

    player = new Player();

    PFont font = createFont("pixelfont.ttf", 50);
    textFont(font);

    maxTime = 10;
    
    upgrades = new Upgrade[]{
        new MiningUpgrade(new int[]{1, 2, 3, 4, 5}, new int[][]{
            null,
            {20, 10, 0, 0},
            {10, 15, 15, 0},
            {0, 20, 30, 10},
            {0, 0, 40, 20},
        }),
        new TimeUpgrade(new int[]{10, 15, 20, 30, 45}, new int[][]{
            null,
            {15, 15, 0, 0},
            {10, 20, 10, 0},
            {0, 10, 30, 20},
            {0, 0, 30, 30},
        }),
    };
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
    for (int i = 0; i < 50; i++) {
        grid[int(random(50 * w))] = new Iron(0);
    }
    
    // gold randomly dispersed
    for (int i = 0; i < 50; i++) {
        grid[int(random(50 * w))] = new Gold(0);
    }
    
    // Clocks randomly dispersed
    for (int i = 0; i < 5; i++) {
        grid[int(random(50 * w))] = new Clock(0);
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
    for (int i = 0; i < 50; i++) {
        grid[50 * w + int(random(50 * w))] = new Iron(1);
    }
    
    // gold randomly dispersed
    for (int i = 0; i < 50; i++) {
        grid[50 * w + int(random(50 * w))] = new Gold(1);
    }
    
    // titanium randomly dispersed
    for (int i = 0; i < 50; i++) {
        grid[50 * w + int(random(50 * w))] = new Titanium(1);
    }
    
    // Clocks randomly dispersed
    for (int i = 0; i < 5; i++) {
        grid[50 * w + int(random(50 * w))] = new Clock(1);
    }
}

public void draw() {
  
    if (newRoundTrue) {
        if (leftPressed|| rightPressed|| downPressed){
          newRoundTrue = false;
        }

        player.position = new PVector(width/2, -2);

        shopTime = 0;
        remainingTime = maxTime;
        slide = -1000;
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
    
    // depth banner and max Tracker
    drawBanner();
    if (currDepth >= record){
      record = currDepth;
    }
    drawBannerRecord();
    
    //Main game stopwatch
    drawStopwatch(newRoundTrue || gamePaused);
    
    //Round timer
    drawRoundTimer(newRoundTrue || gamePaused); 

    //Tracking stopwatch and time remaining in the case of a continuing game
    if (gamePaused == false){ //DIGGING PHASE
        remainingTime -= (1.0/60); //60 to account for a 60fps game
        if (remainingTime < (0)){
            gamePaused = true;
        }
        if (frameCount % 60 == 0 && !newRoundTrue){
            currSec++;
            if (currSec > 60){
                currSec = 0;
                currMin++;
            }
        }  
    }
    else{ //SHOP PHASE        
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
    text(currDepth + "m", 10, 320);
}

public void drawBannerRecord() {
    image(RECORD_BANNER_SPRITE, 0, record);
    fill(#ffffff);
    textSize(15);
    text(record + "m", 10, 320);
}

public void drawRoundTimer(boolean stopped) {
    fill(#a8a7a6);
    rect(15, 15, 300, 20);
    
    if (stopped)
        fill(#0394fc);
    else
        fill(#e95c50);
    
    rect(18, 18, (float)(remainingTime / maxTime * 294), 14);
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
    
    fill(#ffffff);

    // resources
    for (int i = 0; i < resources.length; i++) {
        textSize(20);
        
        float y = 380 + i * 60;
        
        image(RESOURCE_SPRITES[i], (float) slide + 530, y);
        text(resources[i], (float) slide + 580, y + 25);
    }
    
    // mining speed upgrade
    for (int i = 0; i < upgrades.length; i++) {
        int yOffset = i * 100;
        textSize(15);
        text(upgrades[i].name, (float) slide + 120, 380 + yOffset);
        for (int j = 0; j < resources.length; j++) {
            textSize(15);
            
            float x = (float) slide + 120 + j * 60;
            
            image(RESOURCE_SPRITES[j], x, 390 + yOffset);
            text(upgrades[i].getPrice()[j], x + 15, 450 + yOffset);
        }
        
        textSize(15);
        
        if (upgrades[i].canAfford())
            fill(#b5c76d);
        else
            fill(#d1263c);
        
        rect((float)slide + 380, 400 + yOffset, 50, 30);
        fill(#ffffff);
        text("BUY", (float) slide + 390, 420 + yOffset); 
    }
    
    
    // play again button
    textSize(15);
    fill(#3db1eb);
    rect((float)slide + 120, 600, 60, 30);
    fill(#ffffff);
    text("PLAY", (float) slide + 130, 620);
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

        tint((int)(grid[i].health / grid[i].maxHealth * 80 + (255-80)));
        image(grid[i].sprite, col * TILE_SIZE, row * TILE_SIZE - cameraOffset);
    }
}

public void keyPressed() {
    if (gamePaused == false) {
        if (key == 'a')
            leftPressed = true;
        if (key == 'd')
            rightPressed = true;
        if (key == 's')
            downPressed = true;
    }
}

public void mouseClicked() {
    // only time we need mouse clicks are when we're in the shop
    if (gamePaused && shopTime > 1) {
        // continue game
        if (mouseX > 120 && mouseX < 180 && mouseY > 600 && mouseY < 630) {
            setupGrid();
            newRoundTrue = true;
            gamePaused = false;
        }
        
        // mining upgrade
        if (mouseX > 380 && mouseX < 430 && mouseY > 400 && mouseY < 430) {
            if (upgrades[0].canAfford())
                upgrades[0].upgrade();
        }
        
        // time upgrade
        if (mouseX > 380 && mouseX < 430 && mouseY > 500 && mouseY < 530) {
            if (upgrades[1].canAfford())
                upgrades[1].upgrade();
        }
        
        /*if ()
        
        
        
        */
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
