extends Node3D


var current_building = null


func get_mouse_collider():
	var space_state = get_world_3d().direct_space_state
	var cam = $Camera3D
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * 1000
	var query = PhysicsRayQueryParameters3D.create(origin, end)

	var result = space_state.intersect_ray(query)
	return result


func _input(event: InputEvent) -> void:
	if not current_building:
		return

	if event.is_action_pressed("select"):
		var result = get_mouse_collider()
		if result.has("position"):
			$BuildingPlaced.play(2)
			current_building = null
	elif event.is_action_released("rotate_left"):
		current_building.rotate_y(deg_to_rad(15))
	elif event.is_action_released("rotate_right"):
		current_building.rotate_y(deg_to_rad(-15))
	elif event is InputEventMouseMotion:
		var result = get_mouse_collider()
		if result.has("position"):
			result.position.y = 0
			current_building.move(result.position)
	
