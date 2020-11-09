extends Node

var Resources = []
var UI = []
var Units = []
var Fights = []
var Buildings = []

var objectOrdering = [Resources, UI, Units, Fights, Buildings]

# Utility vars
var TIME_CONSTANT = 0.02
var myTimer = 0.02
var incInWhile = 0
var incOutWhile = 0
var incremented = false

func _ready():
	pass 

func _process(delta):
	myTimer -= delta
	
	while myTimer < 0:
		myTimer += TIME_CONSTANT
		update_objects()

func update_objects():
	for group in objectOrdering:
		for item in group:
#			if group != Resources and group != UI and group != Units and group != Buildings:
#				print(item)
			item.time_Update()

func update_once():
	update_objects()

func object_addItemToGroup(object, group):
	match group:
		"Resources":
			Resources.append(object)
		"UI":
			UI.append(object)
		"Units":
			Units.append(object)
		"Fights":
			Fights.append(object)
		"Buildings":
			Buildings.append(object)


func object_removeItemFromGroup(object, group):
	var groupToRemove
	match group:
		"Resources":
			groupToRemove = Resources
		"UI":
			groupToRemove = UI
		"Units":
			groupToRemove = Units
		"Fights":
			groupToRemove = Fights
		"Buildings":
			groupToRemove = Buildings
			
	for item in groupToRemove:
		if item == object:
			groupToRemove.erase(object)

func time_pause():
	set_process(false)

func time_start():
	set_process(true)

