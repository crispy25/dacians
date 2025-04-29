extends Node3D

var radius = 1


func has_point(point: Vector2):
	return (point.x - position.x) ** 2 + (point.y - position.z) ** 2 <= radius * radius


func increase_selection_size(increment: float = 0.5):
	$MeshInstance3D.mesh.bottom_radius += increment
	radius += increment


func decrease_selection_size(decrement: float = 0.5):
	$MeshInstance3D.mesh.bottom_radius -= decrement
	radius -= decrement
