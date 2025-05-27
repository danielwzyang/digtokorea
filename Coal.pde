class Coal extends Square {
    public Coal(int layer) {
        super(SQUARE_HEALTH[layer], COAL_SPRITES[layer]);
    }
    
    @Override
    public void breakSquare() {
        resources[COAL]++;
    }
}
