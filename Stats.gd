# Stats class
public class Stats {
	private int curHP;
	private int maxHP;
	private int strength;
	private int dexterity;
	
	public void setCurHP(int value){
		curHP = curHP - value;
	}
	
	public int getCurHP(){
		return this.curHP;
	}
	
	public void addNewItemStats(Item item){
		this.strength += item.getStrength()
		this.dexterity += item.getDexterity()
		# etc.
	}
	
	# blah blah
}

