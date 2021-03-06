extends Node

var tile_portrait
var trigger_portrait
var description
var parent
var eventType = "popup_TextOnly"
var leftRightString = "EventHolder/EventUpperHolder/EventPanel/LeftRightHolder/"

onready var UIRef = get_tree().get_root().get_node("Control/UI")
onready var leftRightRef = UIRef.get_node("EventHolder/EventUpperHolder/EventPanel/LeftRightHolder")
onready var rootRef = get_tree().get_root().get_node("Control")
onready var timeController = rootRef.timeController
onready var resourceController = rootRef.resourceController
onready var inputController = rootRef.inputController

func _ready():
	pass 
	
func _init():
	tile_portrait = preload("res://MainGame/Tiles/Resources/Question_Mark.png")
#	description
	pass

func triggerEvent():
	# Shows the event on UI
	UIRef.get_node("EventHolder").show()
	print("TRIGGERED")
	UIRef.get_node("EventHolder/EventUpperHolder/EventPanel/LeftRightHolder/PictureContainer/Picture").texture = trigger_portrait
	UIRef.get_node("EventHolder/EventUpperHolder/EventPanel/LeftRightHolder/popup_TextOnly/Panel/Label").text = description
	hideOtherEventTypes()
	
	# This picks the specific eventType to show once the eventScreen is up.
	leftRightRef.get_node(str(eventType)).show()
	
	# Pauses all game functions
	timeController.time_pause()
	event_start()

func event_start():
	inputController.event_addListener(self)
	event_details()
	
func event_end():
	timeController.time_start()
	print("hiding")
	UIRef.get_node("EventHolder").hide()
	inputController.event_removeListener()
	parent.event_remove()
	
func event_details():
	# This should be overwritten in the events that extend this class
	pass

func hideOtherEventTypes():
	leftRightRef.get_node("popup_2Choices").hide()
	leftRightRef.get_node("popup_TextOnly").hide()
	

func get_type():
	return "popup"
	
func get_description():
	return description
	
func get_portrait():
	return tile_portrait

func add_parent(tile):
	parent = tile

func input_receive(event):
	print("input received")
	if !event.is_pressed() and event.button_index == 1:
		event_end()
