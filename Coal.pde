class Coal extends Square {
    public Coal() {
        super(15, COAL_SPRITE);
    }
    
    @Override
    public void breakSquare() {
        resources[COAL]++;
    }
}
