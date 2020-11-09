public class Character {
	private String name;
	private Stats MyStats = new Stats();
	private Item MyItemBox = new Item();
	
	# Strength Check
	
	public liftBoulder(){
		if MyStats.getStrength() > 10 {
			print("Success")
		}
		else {
			print("too weak nerd")
		}
	}
	
	public getNewItem(){
		String newItem = MyItemBox.getNewItem();
		print("You've received the " + newItem)
		
		MyStats.addNewItemStats(MyItemBox.getStatsOfItem(newItem))
	}
}
