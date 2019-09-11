extends Control

func _ready():
	pass
	
func _on_NewGameButton_pressed():
	get_tree().change_scene("res://MainGame/MainGame.tscn")
