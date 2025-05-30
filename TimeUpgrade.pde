class TimeUpgrade extends Upgrade {
    public TimeUpgrade(int[] values, int[][] prices) {
        super("Round Timer", values, prices); 
    }
    
    public void upgrade() {
         super.upgrade();
      
         maxTime = getValue();
    }
}
