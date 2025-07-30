extends Area2D

export var duration := 5.0  # seconds the shield will last on player

func _ready():
	connect("body_entered", self, "_on_body_entered")

func _on_body_entered(body):
	$PowerUp.stream.loop = false
	$PowerUp.play()
	yield($PowerUp, "finished")
	if body.is_in_group("Player"):
		body.activate_shield(duration)
		queue_free()  # Destroy the power-up
