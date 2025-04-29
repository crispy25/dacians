extends Node3D

@onready var multiple_selection = $MultipleSelection
@onready var troops_node: Node3D = $Troops


var available_troops = []
var unavailable_troops = Dictionary()
var selected_troops = Dictionary()
var selection = null

var dacian_scene = preload("res://Troops/Dacian.tscn")
var knight_scene = preload("res://Troops/knight.tscn")
var archer_scene = preload("res://Troops/archer.tscn")


func test_battle_formation():
	var troops = 0
	var enemies = 0

	for i in range(0, 9):
		for j in range(1, 20):
			troops += 1

			var dacian: Troop = dacian_scene.instantiate()
			dacian.position.x = -30 + i * 8
			dacian.position.z = -40 - j * 8

			troops_node.call_deferred("add_child", dacian)
			available_troops.append(dacian)

	for i in range(0, 9):
		for j in range(1, 20):
			troops += 1

			var dacian: Troop = dacian_scene.instantiate()
			dacian.position.x = 40 + i * 8
			dacian.position.z = -40 - j * 8

			troops_node.call_deferred("add_child", dacian)
			available_troops.append(dacian)
			
	for i in range(-2, 14):
		for j in range(1, 10):
			enemies += 1
			
			var knight: Troop = knight_scene.instantiate()
			knight.position.x = i * 8
			knight.position.z = 20 + j * 6
			knight.rotate_y(deg_to_rad(180))

			troops_node.call_deferred("add_child", knight)
			available_troops.append(knight)
			
	for i in range(0, 12):
		for j in range(0, 1):
			enemies += 1

			var archer: Troop = archer_scene.instantiate()
			archer.position.x = i * 8
			archer.position.z = 90 + j * 6
			archer.rotate_y(deg_to_rad(180))

			troops_node.call_deferred("add_child", archer)
			available_troops.append(archer)
		
	#$BattleTimer.start()
	$MusicPlayer.play()

	$BattleUI.troops_count = troops
	$BattleUI.enemies_count = enemies


func test_battle_formation_for_web():
	$BattleUI.troops_count = 0
	$BattleUI.enemies_count = 0
	for i in range(-2, 14):
		$BattleUI.troops_count += 1
		var dacian: Troop = dacian_scene.instantiate()
		dacian.position.x = 20 + i * 6
		dacian.position.z = -10

		$Troops.call_deferred("add_child", dacian)

	for i in range(-3, 10):
		$BattleUI.enemies_count += 1

		var knight: Troop = knight_scene.instantiate()
		knight.position.x = 20 + i * 6
		knight.position.z = 60
		knight.rotate_y(deg_to_rad(180))

		$Troops.call_deferred("add_child", knight)
		
	for i in range(0, 3):
		$BattleUI.enemies_count += 1

		var archer: Troop = archer_scene.instantiate()
		archer.position.x = 40 + i * 4
		archer.position.z = 70
		archer.rotate_y(deg_to_rad(180))

		
		$Troops.call_deferred("add_child", archer)

	$BattleTimer.start()
	$MusicPlayer.play()


func start_attack():
	for troop in available_troops:
		troop.get_node("EnemyDetectionTimer").start()


func _ready() -> void:
	$ChangeSceneUI.fade_out()
	test_battle_formation()
	#test_battle_formation_for_web()
	multiple_selection.hide()


func set_troops_destination(destination):
	for troop in selected_troops:
		if troop == null or troop.is_queued_for_deletion():
			continue
		troop.set_commanded_destination(destination)


func get_mouse_collider():
	var space_state = get_world_3d().direct_space_state
	var cam = $Camera3D
	var mousepos = get_viewport().get_mouse_position()

	var origin = cam.project_ray_origin(mousepos)
	var end = origin + cam.project_ray_normal(mousepos) * 500
	var query = PhysicsRayQueryParameters3D.create(origin, end)

	var result = space_state.intersect_ray(query)
	return result


func select_troop(troop):
	if troop.tribe != 'Dacian':
		return

	troop.toggle_selection(true)
	selected_troops[troop] = true


func select_troops():
	available_troops = $Troops.get_children()

	for troop in available_troops:
		if multiple_selection.has_point(Vector2(troop.position.x, troop.position.z)):
			select_troop(troop)


func unselect_troop(troop):
	if troop == null or troop.is_queued_for_deletion():
		return
	troop.toggle_selection(false)
	

func unselect_troops():
	for troop in selected_troops:
		unselect_troop(troop)
	selected_troops.clear()


func is_troop_selected(sel):
	return sel and sel.collider is CharacterBody3D and sel.collider.selectable


func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		selection = get_mouse_collider()

		if event.is_action_pressed("select"):

			if is_troop_selected(selection):
				select_troop(selection.collider)
			elif selection:
				set_troops_destination(selection.position)

		if event.is_action_released("select_multiple"):
			#select_troops()
			multiple_selection.show()

		if event.is_action("rotate_left") and multiple_selection.visible:
			multiple_selection.increase_selection_size()
		if event.is_action("rotate_right") and multiple_selection.visible:
			multiple_selection.decrease_selection_size()
	elif multiple_selection.visible and event is InputEventMouseMotion:
		var result = get_mouse_collider()
		if result.has("position"):

			multiple_selection.position = result.position
			multiple_selection.position.y = 0.5
			select_troops()

	elif event.is_action_pressed("ui_cancel"):
		unselect_troops()
		multiple_selection.hide()


func is_valid_troop(troop):
	return troop and not troop.to_be_freed


func _on_battle_timer_timeout() -> void:
	var troops = available_troops.filter(is_valid_troop)

	var tribes = {}
	for troop in troops:
		tribes[troop.tribe] = true


	if tribes.size() == 1:
		for troop in troops:
			troop.battle_cheer()
			
		if troops[0].tribe == 'Dacian':
			$BattleUI.show_win()
		else:
			$BattleUI.show_lose()
			$BattleLost.play(1)

		$BattleTimer.stop()
		$MusicPlayer.stop()

		$BattleFinishTimer.start()


func _on_battle_finish_timer_timeout() -> void:
	$ChangeSceneUI.change_scene()


func _on_troops_child_exiting_tree(node: Node) -> void:
	unavailable_troops[node] = true

	$BattleUI.update()

	if unavailable_troops.size() == available_troops.size():
		$BattleFinishTimer.start()
