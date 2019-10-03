extends Panel

const BASE_PORTRAIT = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Base.png")
const MANA_PORTRAIT = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Mana.png")
const MILITARY_PORTRAIT = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Military.png")
const RESOURCE_PORTRAIT = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Resource.png")
const UTILITY_PORTRAIT = preload("res://MainGame/UI/Resources/Portraits/PH_UI_Portrait_Utility.png")

const BASE_DESCRIPTION = "    The Center of Control for your operations. Provides basic resources along with " + \
	"access towards various upgrades."
const MANAPOOL_DESCRIPTION = "    This tile provides a steady supply of Mana to your CoC. It may be upgraded to " + \
	"increase the amount of mana generated, or even to provide healing towards troops stationed here."
const MILITARY_DESCRIPTION = "    This building creates troops for your army. It must be supplied with enough " + \
	"supplies to continue this production."
const UTILITY_DESCRIPTION = "    This does something, Utility is rather vague and can be a lot of things lmao"
const RESOURCE_DESCRIPTION = "    This building creates some arbitrary resource. Maybe it also consumes other " + \
	"resources to do so. idk"
	
var description = "TILE DESCRIPTION: NEEDS TO BE CHANGED"
var portrait = "Blank portrait??"

var buildingName = "Blank"
var buildingTime = 69
var buildingTimeMax = 69
var buildingComplete = false
var percentBuilt = 0

var outputMana = null
var outputUnit = null
var outputAdvanced = null
var outputResearch = null

var selected = false


func _process(delta):
	buildingTime -= delta
	if buildingTime <= 0:
		buildingTime = 0
		set_process(false)
		buildingComplete = true
		get_node("BuildingProgressBar").hide()
	else:
		percentBuilt = (buildingTimeMax - buildingTime) / buildingTimeMax * 100
		get_node("BuildingProgressBar").set("value", percentBuilt)
# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)
	pass # Replace with function body.

func startBuilding():
	pass

func createTile():
	match buildingName:
		"Base":
			description = BASE_DESCRIPTION
			portrait = BASE_PORTRAIT
			buildingTime = 0
			updateOutput(10, 1, 0, 3)

		"ManaPool":
			description = MANAPOOL_DESCRIPTION
			portrait = MANA_PORTRAIT
			buildingTime = 10
			updateOutput(5, null, null, null)

		"ResourceBldg":
			description = RESOURCE_DESCRIPTION
			portrait = RESOURCE_PORTRAIT
			buildingTime = 0.5
			updateOutput(-2, null, 1, null)

		"MilitaryBldg":
			description = MILITARY_DESCRIPTION
			portrait = MILITARY_PORTRAIT
			buildingTime = 1
			updateOutput(null, 3, null, 0)

		"UtilityBldg":
			description = UTILITY_DESCRIPTION
			portrait = UTILITY_PORTRAIT
			buildingTime = 15
			updateOutput(null, null, null, 5)

		_:
			print("Tile.gd: No name match, given -" + buildingName)


	buildingTimeMax = buildingTime
	get_node("BuildingProgressBar").show()
	set_process(true)

func updateOutput(mana, unit, advanced, research):
	outputMana = mana
	outputUnit = unit
	outputAdvanced = advanced
	outputResearch = research

func _on_Button2_pressed():
	print("Tile Pressed!")

