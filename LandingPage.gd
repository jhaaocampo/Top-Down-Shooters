extends Control

onready var direction_panel = $TextureButton/htpButton/DirectionPanel
onready var exit_button = $TextureButton/htpButton/XButton
const world = "res://world.tscn"
const LevelPage = "res://LevelPage.tscn"

func _ready():
	direction_panel.hide()
	exit_button.hide()
	
	$TextureButton.connect("pressed", self, "_on_Start_pressed")
	$TextureButton/htpButton.connect("pressed", self, "_on_htpButton_pressed")
	$TextureButton/htpButton/XButton.connect("pressed", self, "_on_CloseDirection_pressed")

func _on_Start_pressed():
	if direction_panel.visible:
		return
	$ButtonSound.stream.loop = false
	$ButtonSound.play()
	yield($ButtonSound, "finished")
	get_tree().change_scene(LevelPage)

func _on_htpButton_pressed():
	$ButtonSound.stream.loop = false
	$ButtonSound.play()
	get_viewport().set_input_as_handled()
	direction_panel.show()
	exit_button.show()
	
func _on_CloseDirection_pressed():
	get_viewport().set_input_as_handled()
	$ButtonSound.stream.loop = false
	$ButtonSound.play()
	direction_panel.hide()
	exit_button.hide()
