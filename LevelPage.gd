extends Control

const WorldOne = "res://world.tscn"
const LandingPage = "res://LandingPage.tscn"

func _ready():
	$Lvl1.connect("pressed", self, "_on_Start_pressed")
	$HomeButton.connect("pressed", self, "_on_HomeButton_pressed")
	
func _on_Start_pressed():
	$ButtonSound.stream.loop = false
	$ButtonSound.play()
	yield($ButtonSound, "finished")
	get_tree().change_scene(WorldOne)

func _on_HomeButton_pressed():
	$ButtonSound.stream.loop = false
	$ButtonSound.play()
	yield($ButtonSound, "finished")
	get_tree().change_scene(LandingPage)
