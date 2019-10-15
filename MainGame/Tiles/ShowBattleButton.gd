extends Button

func _ready():
	hide()
	var battleScreen = get_tree().get_root().get_node("Control/BattleScreen")
	connect("pressed", battleScreen, "openBattleScreen", [get_parent().get_parent()])
	var position = get_position()
	set_position(Vector2(position[0] + 60, position[1] + 125))
func getReady():
	show()