class MiningUpgrade extends Upgrade {
    public MiningUpgrade(int[] values, int[][] prices) {
        super("Mining Speed", values, prices); 
    }
    
    public void upgrade() {
         super.upgrade();
      
         player.damage = getValue();
    }
}
