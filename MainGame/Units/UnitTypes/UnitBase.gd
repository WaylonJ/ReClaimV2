extends Node

var currentHP = 666
var maxHP = 666
var offense = 666
var defense = 666
var speed = 666

var baseMaxHP = 666666
var baseOffense = 666666
var baseDefense = 666666
var baseSpeed = 666666

var numUnits = 0

func _ready():
	updateStats()
	pass # Replace with function body.

func addToGroup(num):
	print("Adding to num")
	numUnits += num
	updateStats()
	pass
	
func updateStats():
	currentHP = numUnits * baseMaxHP
	maxHP = numUnits * baseMaxHP
	offense = numUnits * baseOffense
	defense = numUnits * baseDefense
	speed = numUnits * baseSpeed
	
	