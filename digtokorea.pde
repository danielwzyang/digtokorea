import processing.video.*;

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
float bounceText;
boolean goDown;
int[] instructions = {0,1,2,3,4};
int currPage;


// End reached and theme
boolean endReached = false;
boolean endPhase = false;
int endLength = 0;
int cameraCount;
Movie ending;

//Banner depth
float bannerDepth;

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

PImage BANNER_SPRITE, RECORD_BANNER_SPRITE, SHOP_SPRITE, PLAYER_SPRITE, PICKAXE_SPRITE, DIRT_SPRITE, CLAY_SPRITE, STONE_SPRITE, BACKGROUND_SPRITE, ASD_SPRITE, SPACEBAR_SPRITE, MININGSPEED_SPRITE, BOMB_SPRITE;
PImage[] UPGRADE_SPRITES, RESOURCE_SPRITES, CLOCK_SPRITES, COAL_SPRITES, IRON_SPRITES, GOLD_SPRITES, TITANIUM_SPRITES;

int[] resources = { 0, 0, 0, 0 };

//bomb count
int bombCount;
int testX;
int testY;
int playerBlockX;
int playerBlockY;

//Max depth for record keeping
int record;
int currDepth;
double accurateDepth; //This essentially subtracts to ensure that the recordTracker stays in place relative to the moving map

Upgrade[] upgrades;

public void setup() {
    size(750, 1000);
    BOMB_SPRITE = loadImage("sprites/bomb.png");
    MININGSPEED_SPRITE = loadImage("sprites/miningspeed.png");
    SPACEBAR_SPRITE = loadImage("sprites/spacebar.png");
    ASD_SPRITE = loadImage("sprites/asd.png");
    BACKGROUND_SPRITE = loadImage("sprites/start.png");
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
    
    bannerDepth = 357;
    player = new Player();

    PFont font = createFont("pixelfont.ttf", 50);
    textFont(font);

    maxTime = 10;
    
    ending = new Movie(this, "ending.mov");
    
    upgrades = new Upgrade[]{
        new MiningUpgrade(new int[]{2, 3, 4, 5, 6}, new int[][]{
            null,
            {5, 10, 0, 0},
            {10, 15, 15, 0},
            {0, 20, 30, 10},
            {0, 0, 40, 20},
        }),
        new TimeUpgrade(new int[]{10, 13, 15, 20, 25}, new int[][]{
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
    currPage = 0;
    titleScreen = true;
    setupGrid();
    bombCount = 1;
    
    gamePaused = false;
    gameStart = false;
    endReached = false;
    endPhase = false;
    onPage[0] = true;
    onPage[4] = false;
    resources[0] = 0;
    resources[1] = 0;
    resources[2] = 0;
    resources[3] = 0;
    currSec = 0;
    currMin = 0;
    newRoundTrue = true;
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
    playerBlockX = (int)player.position.x/30;
    playerBlockY = (int)(player.position.y + TILE_SIZE * .8)/30;
    if (titleScreen){
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
    else if(endReached){
      ending.play();
      endReached = false;
      endPhase = true;
    }
    else if (endPhase){
      background(#000000);
      image(ending,0,305, 750, 400);
      fill(#000000);
      textSize(20);
      textAlign(CENTER);
      fill(#ffffff);
      text("You made it to Korea!", width/2, 300-20);
      stroke(#FFFFFF);
      fill(#000000);
      rectMode(CENTER);
      rect(width/2, 800, 100, 50);
      fill(#FFFFFF);
      text("Again?", width/2, 806);
      textAlign(LEFT);
      rectMode(LEFT);
      stroke(#000000);
      
    }
    else{
      if (newRoundTrue) {
          if (leftPressed|| rightPressed|| downPressed || key == ' '){
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
      if ((200 * TILE_SIZE)-(1000-(330)) <= currDepth * TILE_SIZE){
        cameraOffset = 200 * TILE_SIZE-1000;
      }
      
      
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
      if (((200 * TILE_SIZE)-(1000-357) <= currDepth * TILE_SIZE) && currDepth < record ){
        drawBannerRecord();
      }
      
      //bombCount
      image(BOMB_SPRITE, -15, 40, 150, 150);
      textSize(20);
      text(bombCount, 50, 65);
      
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
          if (currDepth == 200){
            endReached = true;
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

void movieEvent(Movie ending){
  ending.read();
}

public void drawTitleScreen() {
  image(BACKGROUND_SPRITE,0,0);
  
  if (goDown){
    if (frameCount % 20 == 0){
      bounceText += 5;
    }
    if (bounceText >= 405){
      goDown = false;
    }
  }
  else{
    if (frameCount % 20 == 0){
      bounceText -= 5;
    }
    if (bounceText <= 385){
      goDown = true;
    }
  }
  textSize(77);
  text("DIG TO KOREA", 30, bounceText);
  textSize(40);
  text("START GAME", 220, 490);
}

public void drawPage1(){
  image(BACKGROUND_SPRITE,0,0);
  imageMode(CENTER);
  rectMode(CENTER);
  fill(#FFFFFF);
  rect(width/2, height/2, 4 * width/6, 4 * height/6);
  rect(width/2, 675, 100, 50);
  fill(#000000);
  textSize(27.5);
  textAlign(CENTER);
  text("Welcome to", width/2, 240);
  textSize(35);
  text("DIG TO KOREA", width/2, height/6 + 120);
  textSize(27.5);
  text("Use the\n\n\n\n\n\n\nkeys to move your\ncharacter. It will mine\nin that direction as\n long as that key is \nheld.", width/2, height/3+20);
  textSize(15);
  image(ASD_SPRITE, width/2, 430);
  text("Got it", width/2, 650 + 30);
  imageMode(0);
  shapeMode(0);
}

//Round timer & game timer
//Shop

public void drawPage2(){
  image(BACKGROUND_SPRITE,0,0);
  imageMode(CENTER);
  rectMode(CENTER);
  fill(#FFFFFF);
  rect(width/2, height/2, 4 * width/6, 4 * height/6);
  rect(width/2, 675, 100, 50);
  fill(#000000);
  textSize(27.5);
  image(BOMB_SPRITE, width/2-30, 550, 300, 300);
  text("Use bombs with \n\n\n\n\n\n\n to destroy the \nsurrounding area.", width/2, height/3+20);
  image(SPACEBAR_SPRITE, width/2+50, 430,200,70);
  textSize(15);
  text("Got it", width/2, 650 + 30);
  imageMode(0);
  shapeMode(0);
  //Bomb icon??
}

public void drawPage3(){
  image(BACKGROUND_SPRITE,0,0);
  imageMode(CENTER);
  rectMode(CENTER);
  fill(#FFFFFF);
  rect(width/2, height/2, 4 * width/6, 4 * height/6);
  rect(width/2, 675, 100, 50);
  fill(#000000);
  textSize(27.5);
  text("Use the shop after\neach round\n\n\n\n\n\n\n\n\nto buy bombs and\nupgrades using\nmaterials you mine", width/2, height/3);
  image(SHOP_SPRITE, width/2, 450,400, 140);
  textSize(15);
  text("Got it", width/2, 650 + 30);
  imageMode(0);
  shapeMode(0);
  image(RESOURCE_SPRITES[0], width/4+20, 423, 50, 50);
  image(RESOURCE_SPRITES[1], width/4+80, 423, 50, 50);
  image(RESOURCE_SPRITES[2], width/4+140, 423, 50, 50);
  image(RESOURCE_SPRITES[3], width/4+195, 423, 50, 50);
  image(MININGSPEED_SPRITE, width/4 + 260, 423, 50, 50);
  image(CLOCK_SPRITES[1], width/4 + 330, 433, 30, 30);

}//Add resources as icons

public void drawPage4(){
  image(BACKGROUND_SPRITE,0,0);
  imageMode(CENTER);
  rectMode(CENTER);
  fill(#FFFFFF);
  rect(width/2, height/2, 4 * width/6, 4 * height/6);
  rect(width/2, 675, 100, 50);
  fill(#000000);
  textSize(27.5);
  textAlign(CENTER);
  text("Each game plays\nin rounds.\nDestroy clocks to\n\n\n\n\n\nget more time\n each round\n to dig.\nBreak your record\neach new game\nand get to Korea\n as fast as possible\nHave fun digging!", width/2, height/5+30);
  //image(, width/2, 430,200,70);
  textSize(15);
  text("Got it", width/2, 650 + 30);
  imageMode(0);
  shapeMode(0);
  textAlign(LEFT);
  rectMode(0);
  image(CLOCK_SPRITES[1], width/2-110, 313, 50, 50);
  textSize(50);
  fill(#0394fc);
  text("00:00", width/2, 355);  
}




public void drawBanner() {
    if ((200 * TILE_SIZE)-(1000-357) <= currDepth * TILE_SIZE){
      bannerDepth = 630-(TILE_SIZE * 200.0 - (player.position.y + player.size))+370;
    }
    else{
      bannerDepth = 357;
    }
    image(currDepth >= record ? RECORD_BANNER_SPRITE : BANNER_SPRITE, 0, bannerDepth);
    fill(#ffffff);
    textSize(15);
    text(currDepth + "m", 10, bannerDepth + 20);
}

public void drawBannerRecord() {
    fill(#ffffff);
    textSize(15);
    if ((200 * TILE_SIZE)-(1000-357) <= currDepth * TILE_SIZE){
      image(RECORD_BANNER_SPRITE, 0, (float)((float)(record) * TILE_SIZE) - 30 * (200.0 - 1000.0/30));
      text(record + "m", 10, (float)((float)(record) * TILE_SIZE) - 30 * (200.0 - 1000.0/30) + 20);
    }
    else{
      image(RECORD_BANNER_SPRITE, 0, 357 + (float)((float)record - accurateDepth) * TILE_SIZE);
      text(record + "m", 10, 390-13 + (float)((float)record-accurateDepth) * TILE_SIZE);
    }
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
        //Bomb implementation as it's not quite an upgrade
        image(BOMB_SPRITE, (float)slide + 130, 564, 300, 300);
        image(RESOURCE_SPRITES[1], (float)slide + 282, 579);
        textSize(15);
        text("15", (float)slide + 290, 640);
        image(RESOURCE_SPRITES[2], (float)slide + 352, 579);
        text("15", (float)slide + 360, 640);
        if(resources[1] >= 15 && resources[2] >= 15){
          fill(#b5c76d);
        }
        else{
          fill(#d1263c);
        }
        rect((float)slide + 421, 584, 50, 30);
        fill(#ffffff);
        text("BUY", (float) slide + 431, 584+20); 
        text("bomb", (float)slide + 202, 640);
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
        //Bomb functioning
        if (key == ' ' && bombCount > 0){
           bombCount--;
           int xChange = -3;
           int yChange = -4;
           for (int i = 0; i < 9; i++){
             xChange = -3;
             for (int j = 0; j < 7; j++){
               try{
                 grid[playerBlockX + (playerBlockY * 30) + (yChange * 30) + xChange].takeDamage(100);
                 if (grid[playerBlockX + (playerBlockY * 30) + (yChange * 30) + xChange].isDestroyed()) {
                          grid[playerBlockX + (playerBlockY * 30) + (yChange * 30) + xChange].breakSquare();
                          grid[playerBlockX + (playerBlockY * 30) + (yChange * 30) + xChange] = null;
                 }
               }catch(Exception e){}
               xChange++;
             }
             yChange++;
           }
          
        }
            
    }
}

public void mouseClicked() {
    // only time we need mouse clicks are when we're in the shop
    if (titleScreen){
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
        // Bomb purchase
        if (mouseX > 421 && mouseX < 469 && mouseY > 584 && mouseY < 612) {
            if(resources[1] >= 15 && resources[2] >= 15){
              bombCount++;
              resources[1] -= 15;
              resources[2] -= 15;
            }
        }     
    }
    if (endPhase){ 
      if (mouseX > 326 && mouseX < 424 && mouseY > 764 && mouseY < 822) {
        ending.pause(); 
        setup();
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
