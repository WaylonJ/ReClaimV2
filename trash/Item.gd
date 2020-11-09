public static Item extends Stats{
	
	private ArrayList<String> Items = new ArrayList<String>();
	
	public Item(){
		Items.append("Sword")
		Items.append("Shield")
		Items.append("Wand")
	}
	
	public String getNewItem(){
		# Pick a rand number between 0 and length of Items arrayList - 1
		int rand = Rand(len(this.items) - 1);
		
		String returnItem = Items.get(rand);
		Items.remove(rand);
		return returnItem;
	}
	
	public Item getStatsOfItem(String item){
		Item returnItem = new Item();
		
		match item:
			case "Sword":
				returnItem.setStrength(5);
				returnItem.setDexterity(5);
				break;
			case "Shield":
				returnItem.setStrength(2);
				returnItem.setDexterity(8);
				break;
		return returnItem;
		
	}
}

