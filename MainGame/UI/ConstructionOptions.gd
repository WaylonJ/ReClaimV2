extends VBoxContainer

onready var rootRef = get_tree().get_root().get_node("Control")
onready var databaseRef = rootRef.tileDatabase

var costs = null
var bldg = ''

func _ready():
	set_process(false)
	hide()

func _process(delta):
	if not is_visible():
		set_process(false)
	
	for row in get_children():
		for child in row.get_children():
			bldg = child.get_name()
			if bldg == 'Empty2':
				return
			costs = databaseRef.getUpgradeInfo(bldg, 0)
			print(bldg)
			print(costs)
			
			# Buildable, remove filter
			if rootRef.checkSupply(costs[0], costs[1]):
				child.get_node("InsufficientShadeHolder").hide()
			
			# Not buildable, set filter
			else:
				child.get_node("InsufficientShadeHolder").show()
	


func _on_Constructions_pressed():
	show()
	set_process(true)


func _on_BackButton_pressed():
	hide()
	set_process(false)
