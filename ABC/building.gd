extends StaticBody3D

@onready var collision_node: Area3D = get_node("BuildingArea")

@export var building_area: Rect2
@export var resources_required = {}
@export var path_scene = ""

func move(moving_position):
	if building_area.has_point(Vector2(moving_position.x, moving_position.z)):
		position.x = moving_position.x
		position.z = moving_position.z


func can_place():
	return not collision_node.has_overlapping_areas()
