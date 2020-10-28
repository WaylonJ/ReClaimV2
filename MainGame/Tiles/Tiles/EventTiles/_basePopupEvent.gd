extends Node

var portrait
var description
var parent
var eventType = "popup_TextOnly"
onready var UIRef = get_tree().get_root().get_node("Control/UI")
#onready var rootRef = get_tree().get_root().get_node("Control")

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
	UIRef.get_node("EventPanel").show()
	hideOtherEventTypes()
	
	UIRef.get_node("LeftRightHolder/" + str(eventType)).show()
	

func hideOtherEventTypes():
	UIRef.get_node("LeftRightHolder/TextAndChoices").hide()
	UIRef.get_node("LeftRightHolder/TextOnly").hide()
	

func get_type():
	return "popup"
	
func get_description():
	return description
	
func get_portrait():
	return portrait

func add_parent(tile):
	parent = tile

