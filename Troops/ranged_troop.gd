extends Troop

@onready var arrow_scene = preload("res://arrow.tscn")


func idle():
	velocity.x = 0
	velocity.z = 0
	model_anim_player.play("2H_Melee_Idle")


func attack():
	look_at(enemy_target.global_position, Vector3.UP, true)

	if not can_attack:
		return
	
	can_attack = false
	model_anim_player.play("2H_Ranged_Shoot")
	$AttackTimer.start()

	var arrow: Area3D = arrow_scene.instantiate()
	arrow.owner_tribe = tribe
	arrow.destination = Vector3(enemy_target.global_position.x, enemy_target.global_position.y + 3, enemy_target.global_position.z)
	arrow.position = Vector3(position.x, position.y + 3, position.z)

	get_tree().get_root().call_deferred("add_child", arrow)
	
