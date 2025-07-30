extends KinematicBody2D

var movespeed = 400
var fart = preload("res://Fart.tscn")
var is_dead := false
var is_invincible := false
var lives = 5
var can_fire := true
var shield_active := false
var shield_timer = null
var fart_scale := 1.0
var fart_powerup_timer = null
var player_ref = null  # This should point to the player that emitted the fart
onready var score: int = 0
onready var heart_container = get_node("/root/world/LivesUI/LivesContainer")
onready var ui = get_node("/root/world/ScoreUI/ScoreUI")
onready var collision = $CollisionShape2D
onready var shield_effect = $ShieldEffect
export var fire_cooldown := 0.5
export(int) var stars_to_collect = 27 # Preset

var enemies_killed := 0
export(int) var total_enemies := 4 # Preset

const LandingPage = "res://LandingPage.tscn"

#signal level_one_label
signal game_over
signal collect_stars
signal level_complete

# Called when the node enters the scene tree for the first time.
func _ready():
	$BG.stream.loop = true
	$BG.play()
	#emit_signal("level_one_label")
	pass
	
# warning-ignore:unused_argument
func _physics_process(delta):
	if is_dead:
		return

	var motion = Vector2()

	if Input.is_action_pressed("up"):
		motion.y -= 1
	if Input.is_action_pressed("down"):
		motion.y += 1
	if Input.is_action_pressed("right"):
		motion.x += 1
	if Input.is_action_pressed("left"):
		motion.x -= 1

	motion = motion.normalized()
	move_and_slide(motion * movespeed)

	look_at(get_global_mouse_position())

	if Input.is_action_just_pressed("LMB"):
		fire()
	
	if not is_invincible and not shield_active:
		var overlapping = $Area2D.get_overlapping_bodies()
		for body in overlapping:
			if "Enemy" in body.name:
				handle_player_damage()
				break
		
func fire():
	if not can_fire:
		return
	
	can_fire = false
	
	var fart_instance = fart.instance()
	var offset = Vector2(80, 0).rotated(rotation)
	fart_instance.global_position = global_position + offset
	fart_instance.rotation = rotation
	fart_instance.player_ref = self
	fart_instance.should_follow_player = true
	
	# Scale the fart!
	fart_instance.scale *= fart_scale
	
	get_tree().get_root().add_child(fart_instance)
	
	var cooldown_timer = Timer.new()
	cooldown_timer.wait_time = fire_cooldown
	cooldown_timer.one_shot = true
	cooldown_timer.connect("timeout", self, "_on_fire_cooldown_timeout")
	add_child(cooldown_timer)
	cooldown_timer.start()


func _on_fire_cooldown_timeout():
	can_fire = true

func dead():
	emit_signal("game_over")
	is_dead = true
	
		
func handle_player_damage():
	lives -= 1
	update_heart_ui()

	if lives > 0:
		print("Player hit! Lives left: ", lives)
		$Dying.stream.loop = false
		$Dying.play()
		respawn_with_invincibility()
	else:
		print("Player ran out of lives. Game Over!")
		$GameOver.play()
		$BG.stop()
		dead()
			
func update_heart_ui():
	for i in range(heart_container.get_child_count()):
		heart_container.get_child(i).visible = i < lives
		
func respawn_with_invincibility():
	is_invincible = true
	can_fire = false
	hide()
	set_collision_mask_bit(1, false)  
	yield(get_tree().create_timer(0.5), "timeout")  # Briefly hide before respawning

	show()

	yield(blink_player(2.0), "completed")  # Blink for 2 seconds

	set_collision_mask_bit(1, true)
	is_invincible = false
	can_fire = true

func blink_player(duration := 1.5, interval := 0.15):
	var blink_timer = 0.0
	while blink_timer < duration:
		modulate.a = 0  # Invisible
		yield(get_tree().create_timer(interval), "timeout")
		modulate.a = 1  # Visible
		yield(get_tree().create_timer(interval), "timeout")
		blink_timer += interval * 2
		
func collect_coin(value: int) -> void:
	score += value
	ui.set_score_text(score)
	#$Coin.play()
	
# === PORTAL HANDLING ===
func player_portal():
	set_physics_process(false)
	emit_signal("level_complete")

func _on_Exit_Portal_body_entered(body):
	if body == self:
		if score >= stars_to_collect:
			player_portal()
		else:
			emit_signal("collect_stars")
			print("Collect all stars first!")

#shield
func activate_shield(duration: float):
	if shield_timer:
		shield_timer.queue_free()

	shield_active = true
	is_invincible = true
	shield_effect.visible = true

	shield_timer = Timer.new()
	shield_timer.wait_time = duration
	shield_timer.one_shot = true
	shield_timer.connect("timeout", self, "_on_shield_timeout")
	add_child(shield_timer)
	shield_timer.start()
	blink_shield_before_expire(duration)

func _on_shield_timeout():
	shield_active = false
	shield_effect.visible = false
	is_invincible = false	

func blink_shield_before_expire(duration: float):
	yield(get_tree().create_timer(duration - 1.0), "timeout")

	var blink_timer := 0.0
	var blink_interval := 0.15
	while blink_timer < 1.0 and shield_active:
		shield_effect.visible = false
		yield(get_tree().create_timer(blink_interval), "timeout")
		shield_effect.visible = true
		yield(get_tree().create_timer(blink_interval), "timeout")
		blink_timer += blink_interval * 2

func activate_fart_powerup(duration: float):
	fart_scale = 3.0  # Or whatever size multiplier you want

	if fart_powerup_timer:
		fart_powerup_timer.queue_free()
	
	fart_powerup_timer = Timer.new()
	fart_powerup_timer.wait_time = duration
	fart_powerup_timer.one_shot = true
	fart_powerup_timer.connect("timeout", self, "_on_fart_powerup_timeout")
	add_child(fart_powerup_timer)
	fart_powerup_timer.start()

	print("Fart power-up activated!")

func _on_fart_powerup_timeout():
	fart_scale = 1.0
	print("Fart power-up expired!")

func freeze_enemies(duration: float):
	var enemies = get_tree().get_nodes_in_group("Enemies")  # Make sure your enemies are in this group

	for enemy in enemies:
		if enemy.has_method("freeze"):
			enemy.freeze(duration)
			
func add_enemy_kill():
	enemies_killed += 1
	print("Enemies killed: ", enemies_killed)
