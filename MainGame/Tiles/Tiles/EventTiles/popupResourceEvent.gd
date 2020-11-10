extends "res://MainGame/Tiles/Tiles/EventTiles/_basePopupEvent.gd"

const DEFAULT_MANA = 100
const DEFAULT_ADVANCED = 100

func event_details():
	resourceController.add_resources(DEFAULT_MANA, DEFAULT_ADVANCED)
	timeController.update_once()
	


