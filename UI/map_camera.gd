extends Camera2D


@export var speed = 1000
@export var max_zoom = Vector2.ONE
@export var min_zoom = Vector2.ONE

var moveable_area = Rect2(-800, -400, 1600, 800)


func _process(delta: float) -> void:
	var dir = Input.get_vector("left", "right", "up", "down")
	var velocity = dir * speed * delta
	var next_point = Vector2(position.x + velocity.x, position.y + velocity.y)

	if moveable_area.has_point(next_point):
		position.x += velocity.x
		position.y += velocity.y


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.is_action_released("zoom_out") and zoom > min_zoom:
			zoom -= Vector2.ONE / 10
		elif event.is_action_released("zoom_in") and zoom < max_zoom:
			zoom += Vector2.ONE / 10
