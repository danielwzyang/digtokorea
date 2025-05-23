class Gold extends Square {
    public Gold() {
        super(15, GOLD_SPRITE);
    }
    
    @Override
    public void breakSquare() {
        resources[GOLD]++;
    }
}
