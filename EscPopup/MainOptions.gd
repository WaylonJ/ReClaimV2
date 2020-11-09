extends VBoxContainer

func _ready():
	var y = self.rect_size[1]
	self.set("custom_constants/separation", y / 10)


