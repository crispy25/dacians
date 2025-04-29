class_name Troop extends CharacterBody3D

@onready var model_anim_player: AnimationPlayer = get_child(0).get_node("AnimationPlayer")
@onready var navigation_agent: NavigationAgent3D = get_node("NavigationAgent3D")
@onready var troops_node = get_parent()
@onready var battle_scene = get_parent().get_parent()
#@onready var navigation_agent: Node3D = $SimpleNavigationAgent

@export var tribe = 'Dacian'
@export var attack_range: int = 4
@export var detection_range: int = 20
@export var attack_cooldown: float = 1.5


var commanded_destination = null
var selected = false
var selectable = true
var can_attack = true
var chasing = false
var enemy_target = null
var to_be_freed = false
var last_dir = Vector3.FORWARD
var dir = Vector3.FORWARD
var speed = 0

var enemies_in_range = []


func _ready() -> void:
	model_anim_player.animation_finished.connect(animation_handler)
	model_anim_player.play("Idle")
	$AttackTimer.wait_time = attack_cooldown
	$AudioStreamPlayer3D.pitch_scale = randf_range(1, 1.5)
	speed = randi_range(8, 10)


func idle():
	navigation_agent.set_velocity(Vector3.ZERO)
	model_anim_player.play("Idle")


func animation_handler(animation_name):
	match animation_name:
		"1H_Melee_Attack_Chop":
			if is_instance_valid(enemy_target) and arrived_at_destination(enemy_target.global_position, attack_range):
				enemy_target.get_hit()
			idle()
		"Death_A":
			model_anim_player.stop(true)
		"Idle":
			idle()
		"Cheer":
			model_anim_player.play("Cheer")
		"Running_A":
			model_anim_player.play("Running_A")


func toggle_selection(mode):
	selected = mode

	if mode:
		$SelectionIcon.show()
		$AnimationPlayer.play("selected")
	else:
		$SelectionIcon.hide()


func arrived_at_destination(destination, distance_factor):
	var distance = global_position.distance_to(destination)
	return distance < distance_factor


func check_enemy_target():
	if not is_instance_valid(enemy_target) or enemy_target.to_be_freed: # or enemy_target.is_queued_for_deletion() 
		enemy_target = null
	return enemy_target


func chase(enemy):
	enemy_target = enemy
	commanded_destination = null
	navigation_agent.target_desired_distance = attack_range


func stop_chase():
	enemy_target = null
	idle()


func attack():
	if not can_attack:
		return
	
	can_attack = false
	model_anim_player.play("1H_Melee_Attack_Chop")
	$AttackTimer.start()
	$AudioStreamPlayer3D.play(1)
 

func get_hit():
	if to_be_freed:
		return

	to_be_freed = true
	set_physics_process(false)
	$EnemyDetectionTimer.stop()
	$AttackTimer.stop()
	$CollisionShape3D.set_deferred("disabled", true)
	$SelectionIcon.hide()
	navigation_agent.set_velocity(Vector3.ZERO)
	navigation_agent.avoidance_enabled = false

	die()


func die():
	model_anim_player.play("Death_A")
	battle_scene.troop_hit_signal.emit(tribe)
	$QueueFreeTimer.start()
	#model_anim_player.play("Death_A_Pose")
	#model_anim_player.pause()


func set_commanded_destination(destination: Vector3):
	commanded_destination = destination
	navigation_agent.target_desired_distance = 5
	navigation_agent.set_target_position(destination)


func get_to_destination():
	if enemy_target:
		navigation_agent.set_target_position(enemy_target.global_position)

	if navigation_agent.is_navigation_finished():
		idle()
		return true

	var next_path_position: Vector3 = navigation_agent.get_next_path_position()

	last_dir = dir
	dir = global_position.direction_to(next_path_position)

	var new_velocity: Vector3 = global_position.direction_to(next_path_position) * speed
	navigation_agent.set_velocity(new_velocity)

	rotation.y = lerp_angle(rotation.y, atan2(last_dir.x, last_dir.z), 1)
	model_anim_player.play("Running_A")

	return false


func distance_squared_to(target):
	return (position.x - target.x) * (position.x - target.x) + (position.z - target.z) * (position.z - target.z)


func detect_enemies():
	for troop in troops_node.get_children():
		if troop.tribe != tribe and not troop.to_be_freed:# and distance_squared_to(troop.position) < detection_range:
			enemies_in_range.append(troop)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta

	if check_enemy_target():
		if can_attack and get_to_destination():
			attack()
	elif commanded_destination:
		if get_to_destination():
			commanded_destination = null
	else:
		navigation_agent.set_velocity(Vector3.ZERO)


func is_enemy_valid(enemy):
	return is_instance_valid(enemy) and not enemy.to_be_freed


func target_new_enemy():
	enemies_in_range = enemies_in_range.filter(is_enemy_valid)

	if enemies_in_range.size():
		var closest_enemy = null
		var min_dist = 1000
		for enemy in enemies_in_range:
			var dist = global_position.distance_to(enemy.global_position)
			if dist < min_dist:
				min_dist = dist
				closest_enemy = enemy

		chase(closest_enemy)
		return

	enemy_target = null
	idle()
	$EnemyDetectionTimer.stop()


func _on_enemy_detection_timer_timeout() -> void:
	if check_enemy_target():
		return

	detect_enemies()
	target_new_enemy()


func _on_queue_free_timer_timeout() -> void:
	queue_free()


func _on_attack_timer_timeout() -> void:
	can_attack = true


func battle_cheer():
	velocity = Vector3.ZERO
	model_anim_player.play("Cheer")


func _on_navigation_agent_3d_velocity_computed(safe_velocity: Vector3) -> void:
	velocity = safe_velocity
	move_and_slide()
