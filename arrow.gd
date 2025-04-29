extends Area3D

var force = 64.0
var owner_tribe = ""
var destination = Vector2.ZERO
var to_be_freed = false


func _ready():
	look_at(destination, Vector3.UP)


func _process(delta: float) -> void:
	global_transform.origin -= transform.basis.z.normalized() * force * delta


func _on_timer_timeout() -> void:
	queue_free()


func _on_body_entered(body: Node3D) -> void:
	if to_be_freed:
		return

	if body and body is Troop and body.tribe != owner_tribe:
		to_be_freed = true
		body.get_hit()
		queue_free()
