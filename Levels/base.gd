extends Node3D

@onready var building_ui: Control = $BuildingUI
@onready var resources_ui: Control = $BuildingUI/ResourcesUI

var current_building = null

func _ready() -> void:
	for building_info in Global.buildings:
		var building_scene = load(building_info[0]).instantiate()
		building_scene.position = building_info[1]
		building_scene.scale = building_info[2]
		building_scene.rotation = building_info[3]

		$Buildings.call_deferred("add_child", building_scene)


func get_mouse_collider():
	var space_state = get_world_3d().direct_space_state
	var cam = $Camera3D
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, end)

	var result = space_state.intersect_ray(query)
	return result


func place_building():
	resources_ui.remove_resources(current_building.resources_required)
	Global.buildings.append([current_building.path_scene, current_building.position, current_building.scale, current_building.rotation])
	$BuildingPlaced.play(2)
	current_building = null

func _input(event: InputEvent) -> void:
	if not current_building:
		return

	if event.is_action_pressed("select"):
		var result = get_mouse_collider()
		if result.has("position") and current_building.can_place() and resources_ui.has_resources(current_building.resources_required):
			place_building()
		else:
			current_building.queue_free()
			$BuildingNotPlaced.play(2)
			current_building = null
	elif event.is_action_released("rotate_left"):
		current_building.rotate_y(deg_to_rad(15))
	elif event.is_action_released("rotate_right"):
		current_building.rotate_y(deg_to_rad(-15))
	elif event.is_action_released("esc"):
		current_building.queue_free()
		current_building = null
	elif event is InputEventMouseMotion:
		var result = get_mouse_collider()
		if result.has("position"):
			result.position.y = 0
			current_building.move(result.position)
	
