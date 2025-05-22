class Coal extends Square {
    public Coal() {
        super(20, COAL_SPRITE);
    }
    
    public void breakSquare() {
        resources[COAL]++;
    }
}
