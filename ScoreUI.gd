extends Control

onready var scoreText = get_node("ScoreText")

func set_score_text(score):
	scoreText.text = str(score)

# Called when the node enters the scene tree for the first time.
func _ready():
	scoreText.text = "0"
	

