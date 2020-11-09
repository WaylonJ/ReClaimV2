extends VBoxContainer

onready var rootRef = get_tree().get_root().get_node("Control")
onready var resourceController = rootRef.resourceController
onready var timeController = rootRef.timeController
onready var databaseRef = rootRef.tileDatabase

var costs = null
var bldg = ''

func _ready():
	hide()
	
func time_Update():
	if not is_visible():
		timeController.object_removeItemFromGroup(self, "UI")
	
	for row in get_children():
		for child in row.get_children():
			bldg = child.get_name()
			if bldg == 'Empty2':
				return
#			print(bldg)
			costs = databaseRef.getUpgradeInfo(bldg, 0)
			
			# Buildable, remove filter
			if resourceController.checkSupply(costs[0], costs[1]):
				child.get_node("InsufficientShadeHolder").hide()
			
			# Not buildable, set filter
			else:
				child.get_node("InsufficientShadeHolder").show()

func _on_Constructions_pressed():
	show()
	timeController.object_addItemToGroup(self, "UI")


func _on_BackButton_pressed():
	hide()
	timeController.object_removeItemFromGroup(self, "UI")
