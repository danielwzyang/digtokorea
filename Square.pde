class Square {
    private int health;
    private PImage sprite;
    private double maxHealth;

    public Square(int health, PImage sprite) {
        this.health = health;
        this.sprite = sprite;
        this.maxHealth = health;
    }

    public void takeDamage(int amount) {
        health -= amount;
    }

    public boolean isDestroyed() {
        return health <= 0;
    }

    public void breakSquare() {
     
    }
    
}
