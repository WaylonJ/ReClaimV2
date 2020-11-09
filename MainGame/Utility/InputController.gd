extends Node

var reference_camera = null

var input_camera = true

func _ready():
	reference_camera = get_tree().get_root().get_node("Control/Camera2D")

#func _input(event):
#	if input_camera:
#		reference_camera.input_receive(event)
