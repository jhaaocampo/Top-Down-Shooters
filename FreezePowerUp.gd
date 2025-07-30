extends Area2D

export var duration := 5.0  # How long enemies stay frozen

func _ready():
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	$PowerUp.stream.loop = false
	$PowerUp.play()
	yield($PowerUp, "finished")
	if body.is_in_group("Player"):
		body.freeze_enemies(duration)  # Call method on player
		queue_free()  # Remove the power-up


