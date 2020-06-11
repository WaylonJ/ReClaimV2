extends Panel

onready var tileInfoRef = get_node("../BottomUI/MiddleSection/TileInfo")
onready var panelTextRef = get_node("PanelContainer/TextHolder/PanelText")
onready var costHolderRef = get_node("PanelContainer/CostHolder")
onready var upgradeRef = load("res://MainGame/Tiles/upgradeTile.gd").new()
onready var sellRef = load("res://MainGame/Tiles/sellTile.gd").new()

func _ready():
	hide()
	connectConstructionOptions()
	connectTileActions()
	connectUpgradeMenu()
	
	# Needed for tile upgrades/
	add_child(upgradeRef)
	add_child(sellRef)

func connectConstructionOptions():
	var resourceBldg = "../BottomUI/MiddleSection/NoSelection/ConstructionOptions/TopRow/ResourceBldg"
	var militaryBldg = "../BottomUI/MiddleSection/NoSelection/ConstructionOptions/TopRow/MilitaryBldg"
	var utilityBldg = "../BottomUI/MiddleSection/NoSelection/ConstructionOptions/TopRow/UtilityBldg"
	
	get_node(resourceBldg).connect("mouse_entered", self, "_on_BldgButton_mouseEntered", ["Resource"])
	get_node(resourceBldg).connect("mouse_exited", self, "hidePanel")
	get_node(militaryBldg).connect("mouse_entered", self, "_on_BldgButton_mouseEntered", ["Military"])
	get_node(militaryBldg).connect("mouse_exited", self, "hidePanel")
	get_node(utilityBldg).connect("mouse_entered", self, "_on_BldgButton_mouseEntered", ["Utility"])
	get_node(utilityBldg).connect("mouse_exited", self, "hidePanel")

func _on_BldgButton_mouseEntered(type):
	show()
	match type:
		"Resource":
			panelTextRef.text = "Structures who's main focus is gathering basic resources or enhancing them into something more advanced. \n\n -Mana Pool\n -tempResourceStructre\n -Locked\n -Locked"
		"Military":
			panelTextRef.text = "Structures that produce Units or other benefits towards your military strength.\n\n -Goblin Hut\n -Fairy Garden\n -Locked\n -Locked\n -Locked"
		"Utility":
			panelTextRef.text = "Structures that provide a variety of unique benefits, usually involved in gathering information or enhancing some system.\n\n -Lookout Tower\n -Mana Analyzer\n -Locked"
		_:
			print("Panel.gd: Everything else??")
	
func connectTileActions():
	var upgradeButton = "../BottomUI/MiddleSection/TileActions/TopRow/Upgrade"
	var sellButton = "../BottomUI/MiddleSection/TileActions/TopRow/Sell"
	var pauseButton = "../BottomUI/MiddleSection/TileActions/TopRow/Pause"
	
	get_node(upgradeButton).connect("mouse_entered", self, "_on_TileAction_mouseEntered", ["Upgrade"])
	get_node(upgradeButton).connect("mouse_exited", self, "hidePanel")
	get_node(upgradeButton).connect("pressed", self, "attemptUpgrade")
	get_node(upgradeButton).connect("pressed", self, "refreshPanel")
	get_node(sellButton).connect("mouse_entered", self, "_on_TileAction_mouseEntered", ["Sell"])
	get_node(sellButton).connect("mouse_exited", self, "hidePanel")
	get_node(sellButton).connect("pressed", self, "triggerSell")
	get_node(pauseButton).connect("mouse_entered", self, "_on_TileAction_mouseEntered", ["Pause"])
	get_node(pauseButton).connect("mouse_exited", self, "hidePanel")
#	get_node(pauseButton).connect("pressed", self, "hidePanel")

func _on_TileAction_mouseEntered(type):
	show()
	match type:
		"Upgrade":
			panelTextRef.text = "Increases the tier of this building."
			showCost()
		"Sell":
			panelTextRef.text = "Sells the building, refunds part of the resources that have gone into it. What, you want all of them? Give your Gnomes more rights >:("
		"Pause":
			panelTextRef.text = "Freeze the wages of everyone here, causing them to go on strike. They'll wait patiently inside though and start work immediately if you give them their money back"
		_:
			print("Panel.gd: Everything else??")

func refreshPanel():
	print("refreshing")
	hidePanel()
	_on_TileAction_mouseEntered("Upgrade")

func triggerSell():
	sellRef.sellTile(tileInfoRef.selectedTileGroup)
	hidePanel()
	
func attemptUpgrade():
	upgradeRef.upgradeTile(tileInfoRef.selectedTileGroup)

func connectUpgradeMenu():
	var attackUpg = "../BottomUI/MiddleSection/UpgradeMenu/TopRow/AttackUpg"
	var defenseUpg = "../BottomUI/MiddleSection/UpgradeMenu/TopRow/DefenseUpg"
	var speedUpg = "../BottomUI/MiddleSection/UpgradeMenu/TopRow/SpeedUpg"
	var utilityUnlockUpg = "../BottomUI/MiddleSection/UpgradeMenu/TopRow/UtilityUnlockUpg"
	
	get_node(attackUpg).connect("mouse_entered", self, "_on_Upgrade_mouseEntered", ["AttackUpg"])
	get_node(attackUpg).connect("mouse_exited", self, "hidePanel")
	get_node(attackUpg).connect("pressed", self, "hidePanel")
	get_node(defenseUpg).connect("mouse_entered", self, "_on_Upgrade_mouseEntered", ["DefenseUpg"])
	get_node(defenseUpg).connect("mouse_exited", self, "hidePanel")
	get_node(defenseUpg).connect("pressed", self, "hidePanel")
	get_node(speedUpg).connect("mouse_entered", self, "_on_Upgrade_mouseEntered", ["SpeedUpg"])
	get_node(speedUpg).connect("mouse_exited", self, "hidePanel")
	get_node(speedUpg).connect("pressed", self, "hidePanel")
	get_node(utilityUnlockUpg).connect("mouse_entered", self, "_on_Upgrade_mouseEntered", ["UtilityUnlockUpg"])
	get_node(utilityUnlockUpg).connect("mouse_exited", self, "hidePanel")
	get_node(utilityUnlockUpg).connect("pressed", self, "hidePanel")

func _on_Upgrade_mouseEntered(type):
	show()
	match type:
		"AttackUpg":
			panelTextRef.text = "Increases the Damage of <UNIT TYPE> by <DETERMINED AMOUNT> per level"
		"DefenseUpg":
			panelTextRef.text = "Increases the Armor of <UNIT TYPE> by <DETERMINED AMOUNT> per level"
		"SpeedUpg":
			panelTextRef.text = "Increases the Speed of <UNIT TYPE> by <DETERMINED AMOUNT> per level"
		"UtilityUnlockUpg":
			panelTextRef.text = "Unlocks a cool new utility skill that I haven't made yet."

func hidePanel():
	costHolderRef.hide()
	hide()

func showCost():
	costHolderRef.show()
	costHolderRef.setCosts(tileInfoRef.selectedTileGroup[0], tileInfoRef.selectedTileGroup.size())
	

