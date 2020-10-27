extends Node

var portrait
var description

func _ready():
	pass # Replace with function body.
	
func _init():
#	portrait = preload("res://MainGame/Tiles/Resources/Question_Mark.png")
#	description
	pass

func triggerEvent():
	# This will call the UI elements to trigger the event
	# Pause the game
	# Make calls to alter the game
	pass
	
func get_type():
	return "trigger"
	
func get_description():
	return description
	
func get_portrait():
	return portrait


