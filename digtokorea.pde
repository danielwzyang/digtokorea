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

// Title Screen
boolean titleScreen;
int bounceText;
boolean goDown;
int[] instructions = {0,1,2,3,4};
int currPage;
boolean tinting = false;
int currTint;
int tintTime;

//instructions
boolean[] onPage = {true, false, false, false, false};

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
int[] SQUARE_HEALTH = { 30, 60, 90 };

// sprites

PImage BANNER_SPRITE, RECORD_BANNER_SPRITE, SHOP_SPRITE, PLAYER_SPRITE, PICKAXE_SPRITE, DIRT_SPRITE, CLAY_SPRITE, STONE_SPRITE;
PImage[] UPGRADE_SPRITES, RESOURCE_SPRITES, CLOCK_SPRITES, COAL_SPRITES, IRON_SPRITES, GOLD_SPRITES, TITANIUM_SPRITES;

int[] resources = { 1000, 1000, 1000, 1000 };

//int[] MINING_SPEEDS = { 2, 3, 4, 5, 6 };
//int miningIndex = 0;

//Max depth for record keeping
int record;
int currDepth;
double accurateDepth; //This essentially subtracts to ensure that the recordTracker stays in place relative to the moving map

Upgrade[] upgrades;

public void setup() {
    size(750, 5000);

    BANNER_SPRITE = loadImage("sprites/banner.png");
    RECORD_BANNER_SPRITE = loadImage("sprites/record_banner.png");
    SHOP_SPRITE = loadImage("sprites/shop.png");
    PLAYER_SPRITE = loadImage("sprites/player.png");
    PICKAXE_SPRITE = loadImage("sprites/pickaxe.png");

    DIRT_SPRITE = loadImage("sprites/dirt.png");
    CLAY_SPRITE = loadImage("sprites/clay.png");
    STONE_SPRITE = loadImage("sprites/stone.png");
    
    RESOURCE_SPRITES = new PImage[] {
        loadImage("sprites/coal.png"),
        loadImage("sprites/iron.png"),
        loadImage("sprites/gold.png"),
        loadImage("sprites/titanium.png"),
    };
    
    CLOCK_SPRITES = new PImage[] {
        loadImage("sprites/dirt_clock.png"),
        loadImage("sprites/clay_clock.png"),
        loadImage("sprites/stone_clock.png"),
    };

    COAL_SPRITES = new PImage[] {
        loadImage("sprites/dirt_coal.png"),
        loadImage("sprites/clay_coal.png"),
    };

    IRON_SPRITES = new PImage[] {
        loadImage("sprites/dirt_iron.png"),
        loadImage("sprites/clay_iron.png"),
        loadImage("sprites/stone_iron.png"),
    };

    GOLD_SPRITES = new PImage[] {
        loadImage("sprites/dirt_gold.png"),
        loadImage("sprites/clay_gold.png"),
        loadImage("sprites/stone_gold.png"),
    };
    
    TITANIUM_SPRITES = new PImage[] {
        null,
        loadImage("sprites/clay_titanium.png"),
        loadImage("sprites/stone_titanium.png"),
    };

    TILE_SIZE = 30;
    w = 30;
    h = 200;

    grid = new Square[w * h];
    setupGrid();

    player = new Player();

    PFont font = createFont("pixelfont.ttf", 50);
    textFont(font);

    maxTime = 10;
    
    upgrades = new Upgrade[]{
        new MiningUpgrade(new int[]{2, 3, 4, 5, 6}, new int[][]{
            null,
            {5, 10, 0, 0},
            {10, 15, 15, 0},
            {0, 20, 30, 10},
            {0, 0, 40, 20},
        }),
        new TimeUpgrade(new int[]{10, 15, 20, 30, 45}, new int[][]{
            null,
            {10, 5, 0, 0},
            {10, 20, 10, 0},
            {0, 10, 30, 20},
            {0, 0, 30, 30},
        }),
    };
    //Depth and record
    currDepth = int((player.position.y + player.size) / TILE_SIZE);
    record = currDepth;
    
    //To create a titleScreen + instructions
    bounceText = 400;
    currTint = 255;
    currPage = 0;
    titleScreen = true;
    drawGrid();
    saveFrame("full.jpg");
    drawTitleScreen();
    windowResize(750, 1000);
    setupGrid();
    drawGrid();
 
}

public void setupGrid() {
    dirtLayer();
    clayLayer();
    stoneLayer();
}

public void dirtLayer() {
    // rows of dirt
    for (int i = 0; i < 100 * w; i++) {
        grid[i] = new Dirt();
    }
    
    // coal randomly dispersed
    for (int i = 0; i < 100; i++) {
        grid[int(random(50 * w))] = new Coal(0);
    }
    
    // iron randomly dispersed
    for (int i = 0; i < 100; i++) {
        grid[int(random(50 * w))] = new Iron(0);
    }
    
    // gold randomly dispersed
    for (int i = 0; i < 100; i++) {
        grid[int(random(50 * w))] = new Gold(0);
    }
    
    // Clocks randomly dispersed
    for (int i = 0; i < 10; i++) {
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
    for (int i = 0; i < 100; i++) {
        grid[50 * w + int(random(50 * w))] = new Coal(1);
    }
    
    // iron randomly dispersed
    for (int i = 0; i < 100; i++) {
        grid[50 * w + int(random(50 * w))] = new Iron(1);
    }
    
    // gold randomly dispersed
    for (int i = 0; i < 100; i++) {
        grid[50 * w + int(random(50 * w))] = new Gold(1);
    }
    
    // titanium randomly dispersed
    for (int i = 0; i < 100; i++) {
        grid[50 * w + int(random(50 * w))] = new Titanium(1);
    }
    
    // Clocks randomly dispersed
    for (int i = 0; i < 10; i++) {
        grid[50 * w + int(random(50 * w))] = new Clock(1);
    }
}

public void stoneLayer() {
    // spots of clay in dirt layer with increasing densities
    for (int i = 0; i < 20; i++) {
        grid[int(random(10 * w)) + 90 * w] = new Stone();
    }
    for (int i = 0; i < 20; i++) {
        grid[int(random(5 * w)) + 95 * w] = new Stone();
    }
    for (int i = 0; i < 20; i++) {
        grid[int(random(2 * w)) + 98 * w] = new Stone();
    }
  
    // rows of stone
    for (int i = 100 * w; i < 200 * w; i++) {
        grid[i] = new Stone();
    }
    
    // iron randomly dispersed
    for (int i = 0; i < 200; i++) {
        grid[100 * w + int(random(100 * w))] = new Iron(2);
    }
    
    // gold randomly dispersed
    for (int i = 0; i < 200; i++) {
        grid[100 * w + int(random(100 * w))] = new Gold(2);
    }
    
    // titanium randomly dispersed
    for (int i = 0; i < 200; i++) {
        grid[100 * w + int(random(100 * w))] = new Titanium(2);
    }
    
    // Clocks randomly dispersed
    for (int i = 0; i < 20; i++) {
        grid[100 * w + int(random(100 * w))] = new Clock(2);
    }
}


public void draw() {
    //Tracking correct damage amount
    player.damage = upgrades[0].getValue();
    if (titleScreen){
      image(loadImage("full.jpg"), 0, 0); //dirt layer
      loadImage("full.jpg");
      tint(currTint);
      image(loadImage("full.jpg").get(0,1350,750,420), 0, 150); //clay layer
      tint(currTint);
      image(loadImage("full.jpg").get(0,2790,750,520), 0, 480); //stone layer
      if (tinting){
        currTint--;
        if (currTint == 0){
          tinting = false;
        }
      }
      else{
        if (currTint < 255){
          currTint++;
        }
      }
      if (onPage[0]){
        drawTitleScreen();
      }
      else if (onPage[1]){
        drawPage1();
      }
      else if (onPage[2]){
        drawPage2();
      }
      else if (onPage[3]){
        drawPage3();
      }
      else if (onPage[4]){
        drawPage4();
      }
    }
    else{
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
  
      // depth banner
      //currDepth
      currDepth = int((player.position.y + player.size) / TILE_SIZE);
      accurateDepth = (player.position.y + player.size) / TILE_SIZE;
      
      drawBanner();
      if (currDepth < record){
        drawBannerRecord();
      }
      else{ // (currDepth >= record)
        record = currDepth;
      }
      
      
      
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
}

public void drawTitleScreen() {
  if (goDown){
    bounceText += 5;
    if (bounceText == 405){
      goDown = false;
    }
  }
  else{
    bounceText -= 5;
    if (bounceText == 385){
      goDown = true;
    }
  }
  tint(currTint);
  textSize(77);
  text("DIG TO KOREA", 30, bounceText);
  textSize(40);
  text("START GAME", 220, 490);
}

public void drawPage1(){
  fill(#FFFFFF);
  rect(width/6, height/6, 4 * width/6, 4 * height/6);
  rect(325, 650, 100, 50);
  fill(#000000);
  textSize(20);
  text("Instruction page 1", width/6 + 10, height/6 + 40);
  textSize(15);
  text("Got it", 325 + 10, 650 + 30);
}

public void drawPage2(){
  fill(#FFFFFF);
  rect(width/6, height/6, 4 * width/6, 4 * height/6);
  rect(325, 650, 100, 50);
  fill(#000000);
  textSize(20);
  text("Instruction page 2", width/6 + 10, height/6 + 40);
  textSize(15);
  text("Got it", 325 + 10, 650 + 30);
}

public void drawPage3(){
  fill(#FFFFFF);
  rect(width/6, height/6, 4 * width/6, 4 * height/6);
  rect(325, 650, 100, 50);
  fill(#000000);
  textSize(20);
  text("Instruction page 3", width/6 + 10, height/6 + 40);
  textSize(15);
  text("Got it", 325 + 10, 650 + 30);
}

public void drawPage4(){
  fill(#FFFFFF);
  rect(width/6, height/6, 4 * width/6, 4 * height/6);
  rect(325, 650, 100, 50);
  fill(#000000);
  textSize(20);
  text("Instruction page 4", width/6 + 10, height/6 + 40);
  textSize(15);
  text("Got it", 325 + 10, 650 + 30);
}




public void drawBanner() {
    image(currDepth >= record ? RECORD_BANNER_SPRITE : BANNER_SPRITE, 0, 370);
    fill(#ffffff);
    textSize(15);
    text(currDepth + "m", 10, 390);
}

public void drawBannerRecord() {
    image(RECORD_BANNER_SPRITE, 0, 370 + (float)((float)record - accurateDepth) * TILE_SIZE);
    fill(#ffffff);
    textSize(15);
    text(record + "m", 10, 390 + (float)((float)record-accurateDepth) * TILE_SIZE);
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
        fill(#ffffff);
        text(upgrades[i].name, (float) slide + 120, 380 + yOffset);
        if (upgrades[i].getPrice() != null) {
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
        } else {
            fill(#f56942);
            text("MAXED OUT", (float) slide + 120, 410 + yOffset);
        }
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
    if (titleScreen){
      print(mouseX + ",");
      print(mouseY);
      print(currPage);
       if (mouseX > 220 && mouseY > 464 && mouseX < 517 && mouseY < 488 && currPage == 0){
         currPage++;
         onPage[1] = true;
         onPage[0] = false;
       }  
       if(currPage >= 1){
       if (mouseX > 326 && mouseY > 651 && mouseX < 425 && mouseY < 698){
         if (currPage == 4){
           titleScreen = false;
         }
         else{
           currPage++;
           if (currPage == 2){
             onPage[2] = true;
             onPage[1] = false;
           }
           if (currPage == 3){
             onPage[3] = true;
             onPage[2] = false;
           }
           if (currPage == 4){
             onPage[4] = true;
             onPage[3] = false;
           }
         }
       }
    }
  }
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
