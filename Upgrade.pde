class Upgrade {
    private String name;
    private int[] values;
    private int[][] prices;
    private int currentIndex;
  
    public Upgrade(String name, int[] values, int[][] prices) {
         this.name = name;
         this.values = values;
         this.prices = prices;
         currentIndex = 0;
    }
    
    public int getValue() {
        return values[currentIndex];
    }
    
    public int[] getPrice() {
        if (currentIndex == prices.length - 1) {
            return null;
        }
        
        return prices[currentIndex+1];
    }
    
    public boolean canAfford() {
        int[] price = prices[currentIndex + 1];
        for (int resource = 0; resource < price.length; resource++) {
            if (resources[resource] < price[resource]) 
                return false;
        }
        
        return true;
    }
    
    public void upgrade() {
        currentIndex++;
         
        int[] price = prices[currentIndex];
        for (int resource = 0; resource < price.length; resource++) {
            resources[resource] -= price[resource];
        }
    }
}
