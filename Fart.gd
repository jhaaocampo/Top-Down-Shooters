extends Area2D

export var duration := 0.5
export var should_follow_player := false
var player_ref = null

func _ready():
	add_to_group("Fart")
	$Timer.start(duration)
	connect("body_entered", self, "_on_body_entered")
	$BlowSound.stream.loop = false
	$BlowSound.play()
	#yield($BlowSound, "finished")
	$Timer.connect("timeout", self, "queue_free")

func _process(_delta):
	if should_follow_player and is_instance_valid(player_ref):
		global_position = player_ref.global_position + Vector2(80, 0).rotated(player_ref.rotation)
		rotation = player_ref.rotation

func _on_body_entered(body):
	if "Enemy" in body.name:
		body.kill(player_ref)
		queue_free()
		

