extends Area2D

export var value = 1

func _process(delta):
	rotation_degrees += 90 * delta

func _on_Coin_body_entered(body):
	if body.has_method("collect_coin"):
		body.collect_coin(value)
		queue_free()
