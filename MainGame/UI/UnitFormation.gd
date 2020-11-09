extends TextureRect

var unit = null

func _ready():
	pass

func setTexture(texture, updateUnit):
	unit = updateUnit
	self.set("texture", texture)
