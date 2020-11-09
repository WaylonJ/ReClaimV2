extends Node

var portrait
var description
var parent
var eventType = "popup_TextOnly"
var leftRightString = "EventHolder/EventUpperHolder/EventPanel/LeftRightHolder/"
onready var UIRef = get_tree().get_root().get_node("Control/UI")
onready var leftRightRef = UIRef.get_node("EventHolder/EventUpperHolder/EventPanel/LeftRightHolder")
onready var rootRef = get_tree().get_root().get_node("Control")
onready var timeController = rootRef.timeController
onready var resourceController = rootRef.resourceController

func _ready():
	pass 
	
func _init():
#	portrait = preload("res://MainGame/Tiles/Resources/Question_Mark.png")
#	description
	pass

func triggerEvent():
	# This will call the UI elements to trigger the event
	# Pause the game
	# Make calls to alter the game
	
	# Shows the event on UI
	UIRef.get_node("EventHolder").show()
	hideOtherEventTypes()
	
	leftRightRef.get_node(str(eventType)).show()
	
	# Pauses all game functions
	timeController.time_pause()
	event_start()

func event_start():
	pass

func hideOtherEventTypes():
	leftRightRef.get_node("popup_2Choices").hide()
	leftRightRef.get_node("popup_TextOnly").hide()
	

func get_type():
	return "popup"
	
func get_description():
	return description
	
func get_portrait():
	return portrait

func add_parent(tile):
	parent = tile

