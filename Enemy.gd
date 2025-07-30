extends KinematicBody2D

var motion = Vector2()
var original_speed := 1 # Changed to a proper speed value
var speed := 1
var is_frozen := false
var chase_range := 600.0  # How far the enemy can detect the player
var stop_distance := 15.0  # How close before stopping (to prevent jittering)
onready var sprite = $Sprite  # Make sure the node path is correct

func _ready():
	add_to_group("Enemies")
	original_speed = 5
	speed = original_speed
	sprite.play("default")  

func _physics_process(delta):
	if is_frozen:
		return

	var Player = get_parent().get_node("Player")

	if Player:
		# Calculate distance to player
		var distance_to_player = global_position.distance_to(Player.global_position)
		
		# Only chase if player is within chase range
		if distance_to_player <= chase_range and distance_to_player > stop_distance:
			# Calculate direction to player
			var direction = (Player.global_position - global_position).normalized()
			
			# Set motion based on direction and speed
			motion = direction * speed
			
			# Look at player (with some smoothing)
			look_at(Player.position)
		else:
			# Stop when very close or too far to prevent jittering/unnecessary chasing
			motion = Vector2.ZERO
		
		# Use move_and_slide for proper collision detection
		motion = move_and_collide(motion)
		#motion = move_and_slide(motion)
	
func kill(player):
	if player and player.has_method("add_enemy_kill"):
		player.add_enemy_kill()
	queue_free()


func freeze(duration: float):
	if is_frozen:
		return

	is_frozen = true
	speed = 0.0

	sprite.play("frozen")
	yield(get_tree().create_timer(duration), "timeout")

	is_frozen = false
	speed = original_speed
	sprite.play("default")
