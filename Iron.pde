class Iron extends Square {
    public Iron(int layer) {
        super(SQUARE_HEALTH[layer], IRON_SPRITES[layer]);
    }
    
    @Override
    public void breakSquare() {
        resources[IRON]++;
    }
}
