class Player {
    private PVector position;
    private PVector velocity;
    private float size = TILE_SIZE * 0.8;
    private int damage = 1;
    private boolean mirror;
    private float pickaxeSwingAngle = 0;
    private float pickaxeSwingSpeed = 0.2;

    public Player() {
        position = new PVector(width/2, -2);
        velocity = new PVector(0, 0);
    }

    public void move() {
        // handle movement for left and right
        velocity.x = 0;
        if (leftPressed) {
            velocity.x = -1.5;
            mirror = true;
        }
        if (rightPressed) {
            velocity.x = 1.5;
            mirror = false;
        }

        // add gravity
        velocity.y = 4;

        // adjust horizontal position and mine horizontally while resolving any collisions
        position.x += velocity.x;
        position.x = constrain(position.x, 0, width - size);
        if (velocity.x != 0) mine(true);
        resolveCollision(true);

        // adjust vertical position and mine vertically while resolving any collisions
        position.y += velocity.y;
        if (velocity.y != 0) mine(false);
        resolveCollision(false);
    }

    public void draw() {
        noStroke();
        fill(255, 225, 161);

        if (leftPressed || rightPressed || downPressed) {
            pickaxeSwingAngle += pickaxeSwingSpeed;
            if (pickaxeSwingAngle > PI/3 || pickaxeSwingAngle < 0) pickaxeSwingSpeed *= -1;
        } else {
            pickaxeSwingAngle = 0;
        }

        if (mirror) {
            pushMatrix();
            scale(-1, 1);
            image(PLAYER_SPRITE, -position.x - size, position.y - cameraOffset);

            pushMatrix();
            translate(-position.x, position.y - cameraOffset + size);
            rotate(pickaxeSwingAngle);
            image(PICKAXE_SPRITE, -5, -size + 5);
            popMatrix();

            popMatrix();
        } else {
            image(PLAYER_SPRITE, position.x, position.y - cameraOffset);

            pushMatrix();
            translate(position.x + size, position.y - cameraOffset + size);
            rotate(pickaxeSwingAngle);
            image(PICKAXE_SPRITE, -5, -size + 5);
            popMatrix();
        }
    }

    public PVector getPosition() {
        return position;
    }

    private void mine(boolean horizontal) {
        // this is pretty complicated but the basic idea is to check which tiles the player is overlapping with
        // we do this by defining the "bounding box" of the player, which is basically just the space that the player occupies

        // here the bounding box is defined
        float leftBound = position.x;
        float topBound = position.y;
        float rightBound = position.x + size;
        float bottomBound = position.y + size;

        // now we convert this bounding box to rows and columns
        // our grid of squares is an array and we can't just use the player's position directly to find the squares in the grid
        // thus we divide by TILE_SIZE
        int rowStart = constrain(floor(topBound / TILE_SIZE), 0, h - 1);
        int rowEnd   = constrain(floor((bottomBound - 1) / TILE_SIZE), 0, h - 1);
        int colStart = constrain(floor(leftBound / TILE_SIZE), 0, w - 1);
        int colEnd   = constrain(floor((rightBound - 1) / TILE_SIZE), 0, w - 1);

        // here we handle horizontal and vertical collision separately just to make things easier
        if (horizontal) {
            // here we find the potential column of the square that the player is mining
            // if velocity is positive this means that the player is moving to the right, so we want to look at the right bound
            // if it's negative the player is moving to the left so we want to look at the left bound, but we have to subtract by one so we're not looking at the current square
            int col = (velocity.x > 0) ? floor((rightBound) / TILE_SIZE) : floor((leftBound - 1) / TILE_SIZE);
            col = constrain(col, 0, w - 1);
            
            // now we look at our bounding box and specifically the rows since we already know the column
            // this will tell us which possible squares we can mine
            for (int row = rowStart; row <= rowEnd; row++) {
                // since our grid is a 1d array we have to convert these 2d coordinates
                int index = row * w + col; 
                
                // if the current square isn't air
                if (grid[index] != null) {
                    // we do damage to the square
                    grid[index].takeDamage(damage);
                    
                    // if the square is destroyed we break it
                    if (grid[index].isDestroyed()) {
                        grid[index].breakSquare();
                        grid[index] = null;
                    }
                }
            }
        } else if (downPressed) {
            // if the player is holding down that means they can also dig down so we do the same thing as we did before just vertically
            
            // find the row (you can only mine down so there's no need for a ternary operator like for horizontal)
            int row = floor((bottomBound) / TILE_SIZE);
            row = constrain(row, 0, h - 1);
            
            // loop through the columns
            for (int col = colStart; col <= colEnd; col++) {
                // convert to 1d coordinates
                int index = row * w + col;
                
                if (grid[index] != null) {
                    grid[index].takeDamage(damage);
                    if (grid[index].isDestroyed()) {
                        grid[index].breakSquare();
                        grid[index] = null;
                    }
                }
            }
        }
    }


    private void resolveCollision(boolean horizontal) {
        // here we do the same thing as mine and find the bounding box
        
        float leftBound = position.x;
        float topBound = position.y;
        float rightBound = position.x + size;
        float bottomBound = position.y + size;

        int rowStart = constrain(floor(topBound / TILE_SIZE), 0, h - 1);
        int rowEnd   = constrain(floor((bottomBound - 1) / TILE_SIZE), 0, h - 1);
        int colStart = constrain(floor(leftBound / TILE_SIZE), 0, w - 1);
        int colEnd   = constrain(floor((rightBound - 1) / TILE_SIZE), 0, w - 1);

        // this time we loop through the entire bounding box to find any possible collisions
        for (int row = rowStart; row <= rowEnd; row++) {
            for (int col = colStart; col <= colEnd; col++) {
                // convert to 1d to find the current square that we could be colliding with
                int idx = row * w + col;
                
                // ignore air squares
                if (grid[idx] == null) continue;

                // now we calculate the bounding box of the tile
                float tileLeftBound = col * TILE_SIZE;
                float tileTopBound = row * TILE_SIZE;
                float tileRightBound = tileLeftBound + TILE_SIZE;
                float tileBottomBound = tileTopBound + TILE_SIZE;

                // using the bounding boxes we can calculate any possible overlap
                // imagine each component (horizontal and vertical) as an interval
                // to find the intersection of two intervals, we can do some math
                // we want to look at the minimum of the maxs (i.e. the right bounds)
                // and the maximum of the mins (i.e. the left bounds)
                // if the intervals aren't overlapping, the minimum of the right bounds will be behind the maximum of the left bounds
                // therefore the min of the rights - the max of the lefts will be negative
                // we can do the same for the vertical intervals and look at the min of the bottom bounds and the max of the left bounds
                
                // math!!!
                
                /*
                      | |                            | |
                        ^ min of right bound         ^ max of left bound
                */
                
                float overlapX = min(rightBound, tileRightBound) - max(leftBound, tileLeftBound);
                float overlapY = min(bottomBound, tileBottomBound) - max(topBound, tileTopBound);

                // as said before, if the boxes are overlapping the value will be positive
                if (overlapX > 0 && overlapY > 0) {
                    // if the player is moving horizontally we can offset the position accordingly
                    if (horizontal) {
                        // if the player is moving to the right (x velocity > 0) we SUBTRACT the offset
                        // if the player is moving to the left (x velocity < 0) we ADD the offset
                        if (velocity.x > 0) position.x -= overlapX;
                        else if (velocity.x < 0) position.x += overlapX;
                        
                        // now we reset the velocity because the player has hit a wall
                        velocity.x = 0;
                    } else {
                        // we do the same for vertical movement, except they can only move down
                        
                        position.y -= overlapY;
                        
                        velocity.y = 0;
                    }

                    // update player box
                    leftBound = position.x;
                    topBound = position.y;
                    rightBound = position.x + size;
                    bottomBound = position.y + size;
                }
            }
        }
    }
}
