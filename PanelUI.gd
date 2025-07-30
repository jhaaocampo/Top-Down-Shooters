extends CanvasLayer

onready var game_over_label = $GameOverLabel
#onready var level_one_label = $LevelOneLabel
onready var collect_stars_label = $CollectStarsLabel
onready var pause_panel = $PausePanel
onready var complete_panel = $CompletePanel
onready var star1 = $CompletePanel/Star1
onready var star2 = $CompletePanel/Star2
onready var star3 = $CompletePanel/Star3
onready var score_label = $CompletePanel/ScoreLabel  # like "Score: 12/15"

const LandingPage = "res://LandingPage.tscn"
const LevelPage = "res://LevelPage.tscn"
const WorldOne = "res://world.tscn"
const WorldTwo = "res://world.tscn" # there is no worldTwo just a placeholder for continue button function

func _ready():
	game_over_label.hide() 
	#level_one_label.hide()
	collect_stars_label.hide()
	pause_panel.hide() 
	complete_panel.hide()
	star1.hide()
	star2.hide()
	star3.hide()
	
	$PauseButton.connect("pressed", self, "_on_PauseButton_pressed")
	$PausePanel/ResumeButton.connect("pressed", self, "_on_ResumeButton_pressed")
	$PausePanel/RestartButton.connect("pressed", self, "_on_RestartButton_pressed")
	$PausePanel/QuitButton.connect("pressed", self, "_on_QuitButton_pressed")
	$CompletePanel/HomeButton.connect("pressed", self, "_on_HomeButton_pressed")
	$CompletePanel/LevelPageButton.connect("pressed", self, "_on_LevelPageButton_pressed")
	$CompletePanel/RestartButton.connect("pressed", self, "_on_RestartButton_pressed")
	$CompletePanel/ContinueButton.connect("pressed", self, "_on_ContinueButton_pressed")
	
	get_node("/root/world/Player").connect("game_over", self, "_on_Player_game_over")
	get_node("/root/world/Player").connect("level_complete", self, "_on_Player_level_complete")
	get_node("/root/world/Player").connect("collect_stars", self, "_on_Player_collect_stars")
	#get_node("/root/world/Player").connect("level_one_label", self, "_on_Player_level_one")

func _on_Player_game_over():
	game_over_label.show()
	yield(get_tree().create_timer(2.5), "timeout")
	get_tree().change_scene(LandingPage)
	
func _on_Player_level_complete():
	$LevelComplete.play()
	update_stars(get_node("/root/world/Player").enemies_killed, get_node("/root/world/Player").total_enemies)
	complete_panel.show()

func _on_Player_collect_stars():
	collect_stars_label.show()
	yield(get_tree().create_timer(2), "timeout")
	collect_stars_label.hide()
	
func _on_PauseButton_pressed():
	pause_panel.show()
	$ButtonSound.play()
	yield($ButtonSound, "finished")
	get_tree().paused = true

func _on_ResumeButton_pressed():
	pause_panel.hide()
	get_tree().paused = false

func _on_RestartButton_pressed():
	get_tree().paused = false 
	get_tree().reload_current_scene()
	

func _on_QuitButton_pressed():
	get_tree().paused = false
	get_tree().change_scene(LevelPage)
	
func _on_HomeButton_pressed():
	get_tree().change_scene(LandingPage)
	
func _on_LevelPageButton_pressed():
	get_tree().change_scene(LevelPage)
	
func _on_ContinueButton_pressed():
	get_tree().change_scene(WorldTwo)

#func _on_Player_level_one():
#	level_one_label.show()
#	yield(get_tree().create_timer(2.5), "timeout")
#	level_one_label.hide()	
	
func update_stars(kills: int, total: int):
	if total == 0:
		total = 1  # Avoid division by zero

	var percentage := float(kills) / float(total)
	score_label.text = "%d / %d" % [kills, total]
	print("✅update_stars called with kills:", kills, "/", total, "(", percentage * 100, "%)")

	if percentage >= 1.0:
		star1.show()
		star2.show()
		star3.show()
	elif percentage >= 0.66:
		star1.show()
		star2.show()
	elif percentage >= 0.33:
		star1.show()
