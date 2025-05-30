class Titanium extends Square {
    public Titanium(int layer) {
        super(SQUARE_HEALTH[layer], TITANIUM_SPRITES[layer]);
    }
    
    @Override
    public void breakSquare() {
        resources[TITANIUM]++;
    }
}
