extends Node3D

@export var target_desired_distance = 1
@export var speed = 10
@export var random_speed: bool = true

@onready var character = get_parent()

var target = null


func _ready() -> void:
	if random_speed:
		speed = randi_range(8, 12)


func arrived_at_destination(distance_factor):
	var distance = global_position.distance_to(target)
	return distance < distance_factor


func set_velocity(velocity: Vector3):
	character.velocity = velocity
	character.move_and_slide()


func set_target_position(target_position: Vector3):
	target = target_position
	

func is_navigation_finished():
	if not target:
		return true
	
	return arrived_at_destination(target_desired_distance)


func get_next_path_position():
	var current_position: Vector3 = character.global_position
	return current_position + current_position.direction_to(target)
