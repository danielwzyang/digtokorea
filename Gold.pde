class Gold extends Square {
    public Gold(int layer) {
        super(SQUARE_HEALTH[layer], GOLD_SPRITES[layer]);
    }
    
    @Override
    public void breakSquare() {
        resources[GOLD]++;
    }
}
