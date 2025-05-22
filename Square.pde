class Square {
    private int health;
    private PImage sprite;

    public Square(int health, PImage sprite) {
        this.health = health;
        this.sprite = sprite;
    }

    public void takeDamage(int amount) {
        health -= amount;
    }

    public boolean isDestroyed() {
        return health <= 0;
    }

    public PImage getSprite() {
        return sprite;
    }

    public void breakSquare() {
        
    }
}
