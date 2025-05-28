Square[] grid; // grid for all squares on the screen / anything that can be mined
Player player;
int TILE_SIZE; // size for one square
int w, h; // unit is number of squares
float cameraOffset;  

//Time gauging purpose
int currSec;
int currMin;
double maxTime;
double remainingTime;

//Game pause/shop phase
boolean gamePaused = false;
boolean gameStart = false;
double shopTime = 0;

//Restart game phase
boolean newRoundTrue = true;
int countDown = 4;
float countXl = -20;
float countYd = 1050;
float countXr = 770;
float countYu = -50;

// for horizontal movement and digging down
boolean leftPressed;
boolean rightPressed;
boolean downPressed;

// Initial left slide animation
double slide = -1000;
double acceleration = .1;
boolean bounceThreeTimes = true;
int bounceCount = 0;


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
    
    //Setting maximum time
    maxTime = 10;
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
  
    if (newRoundTrue){
      
        if (leftPressed|| rightPressed|| downPressed){
          newRoundTrue = false;
        }
      //textSize(100);
      //if (countDown == 4 && frameCount % 60 == 0){
            player = new Player();
      //}
      shopTime = 0;
      remainingTime = maxTime;
      slide = -1000;
      //if (frameCount % 60 == 0){
      //  countDown--;
      //} 
      //text("hi", 300, 300);
     // if (countDown == 3){
     //   countXl += 12.5;
     //   text(parseInt(countDown), countXl, height/2 - 30);
     // }
     // if (countDown == 2){
     //   countYu += 15;
     //   text(parseInt(countDown), width/2 - 30, countYu);
     // }
     // if (countDown == 1){
     //   countXr -= 12.5;
     //   text(parseInt(countDown), countXr, height/2 - 30);
     // }
      //if (countDown == 0){
        //countYd -= 15;
        //text("GO", width/2 - 30, countYd);
        //countXl = -20;
        //countYd = 1050;
         //countXr = 770;
         //countYu = -50;
        bounceCount = 0;
        bounceThreeTimes = true;
        acceleration = .1;
      //}
      //if (countDown == -1){
         
      //}
    }
  
  
  
  
    background(161, 211, 255);
    //Triggering the start of a game USE SETUP()
    
    player.move();
    cameraOffset = player.position.y - height/3;
    
    drawGrid();

    player.draw();
    
    fill(0, 0, 0);
    
    
    
    //Round timer
    fill(#a8a7a6);
    rect(width/6, height/5, (float)(width * (4.0/6)), 20);
    fill(#e95c50);
    rect(width/(6 - .1), height/(5-.06), (float)(remainingTime / maxTime * (width * (0.661))), 15); //CALCULATED WIDTH BY doing (1 - 2/.59)
    
    //Tracking stopwatch and time remaining in the case of a continuing game
    if (gamePaused == false){ //DIGGING PHASE
      //if (newRoundTrue == false){
      remainingTime -= (1.0/60); //60 to account for a 60fps game
      if (remainingTime < (0)){
        gamePaused = true;
      }
      if (frameCount % 60 == 0 && newRoundTrue == false){
        currSec++;
        if (currSec > 60){
          currSec = 0;
          currMin++;
        }
      }
      //}
      //Main game stopwatch
      textSize(100);
      fill(#000000);
      rect(0,0, (230), (80));
      rect(0,0, (210), (100));
      circle(210,80, 40);
      fill(#0394fc);
      String secondTime = "" + currSec;
      String minTime = "" + currMin;
      if (currSec < 10){
         secondTime = "0" + currSec;
      }
      if (currMin < 10){
         minTime = "0" + currMin;
      }
      text("" + minTime + ":" + secondTime , 0, 80);
    }
    else{ //SHOP PHASE
      //Timer (red)
      textSize(100);
      fill(#000000);
      rect(0,0, (230), (80));
      rect(0,0, (210), (100));
      circle(210,80, 40);
      fill(#fc0352);
      String secondTime = "" + currSec;
      String minTime = "" + currMin;
      if (currSec < 10){
         secondTime = "0" + currSec;
      }
      if (currMin < 10){
         minTime = "0" + currMin;
      }
      text("" + minTime + ":" + secondTime , 0, 80);
      
      
      
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
      
      rect((float)slide + 93.25, height/10, width * (6/8.0), height * (8.0/10));
      rect((float)slide + 93.25-25, height/8, width * (8.0/10) + 12.5, height * (6/8.0)); //Overlapping rectangles with circles for a smoother shape
      circle((float)slide + 93.25, height/8, 50);
      circle((float)slide + 93.25, 7 * height/8, 50);
      circle((float)(slide + 93.25 +562.5), 7 * height/8, 50);
      circle((float)(slide + 93.25 +562.5), height/8, 50);
      fill(#FFFFFF);
      

      rect((float)slide + 100, 150, 550, 250);
      rect((float)slide + 100, 450, 250, 250);
      rect((float)slide + 400, 450, 250, 250);
      rect((float)slide + 100, 750, 250, 100);
      rect((float)slide + 400, 750, 250, 100);
      textSize(50);
      fill(#000000);
      text("SHOP", (float)(slide + 312.5), 140);
      textSize(30);
      text("INVENTORY", (float)(slide + 308), 390); 
      textSize(40);
      text("NEXT ROUND", (float)slide + 415, 812);
      if (frameCount % 60 == 0){
        shopTime++;
      }
    }
    //Depth recorder here
    text((int)((player.getPosition().y + 24) / 30), 300, 100 );
    
    
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

//public void restartGame(){
  
//}

public void mouseClicked(){
  if (mouseX > 400 && mouseX < 650 && mouseY > 750 && mouseY < 850 && gamePaused && shopTime > 2){
    setupGrid();
    newRoundTrue = true;
    gamePaused = false;
  }
}

public void keyReleased() {
  if (gamePaused == false){
    if (key == 'a') leftPressed = false;
    if (key == 'd') rightPressed = false;
    if (key == 's') downPressed = false;
  }
}
