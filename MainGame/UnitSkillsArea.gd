extends VBoxContainer

var skillOneImage
var skillTwoImage
var skillThreeImage

var unitPortrait

func _ready():
	pass 

func initializeArea():
	skillOneImage = load("res://MainGame/Units/Resources/Skills/Blank.png")
	skillTwoImage = load("res://MainGame/Units/Resources/Skills/Blank.png")
	skillThreeImage = load("res://MainGame/Units/Resources/Skills/Blank.png")
	
	setDefaultBGs()
	
func setDefaultBGs():
	var blank = load("res://MainGame/Units/Resources/Skills/Blank.png")
	setSkill(1, blank)
	setSkill(2, blank)
	setSkill(3, blank)
	
	var blankPortrait = load("res://MainGame/Units/Resources/SmallIcons/small_Unit_Blank.png")
	setUnitPortrait(blankPortrait)
	
	
func setSkill(skillNumber, image):
	match skillNumber:
		1:
			get_node("Skills/SkillOne/BG").set("texture", image)
		2:
			get_node("Skills/SkillTwo/BG").set("texture", image)
		3:
			get_node("Skills/SkillThree/BG").set("texture", image)

func setUnitPortrait(image):
	get_node("Unit/Portrait").set("texture", image)
	









