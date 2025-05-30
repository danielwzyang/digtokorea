class Clock extends Square {
    public Clock(int layer) {
        super(SQUARE_HEALTH[layer], CLOCK_SPRITES[layer]);
    }
    
    @Override
    public void breakSquare() {
        remainingTime = maxTime;
    }
}
