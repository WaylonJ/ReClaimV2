extends VBoxContainer

func _ready():
	show()


func _on_Constructions_pressed():
	# Either construction pressed, or a tile was selected
	hide()


func _on_BackButton_pressed():
	show()
