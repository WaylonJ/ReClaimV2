extends "res://MainGame/Tiles/Tiles/EventTiles/_basePopupEvent.gd"

const DEFAULT_MANA = 100
const DEFAULT_ADVANCED = 100

func _init():
	trigger_portrait = preload("res://Resources/Events/Resources.png")
	description = "You've found a stash of resource! Adding " + str(DEFAULT_MANA) + " mana and " + str(DEFAULT_ADVANCED) + " advanced!"

func event_details():
	resourceController.add_resources(DEFAULT_MANA, DEFAULT_ADVANCED)
	timeController.update_once()
	


