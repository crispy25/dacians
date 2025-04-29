extends Node3D

@onready var multiple_selection = $MultipleSelection
@onready var troops: Node3D = $Troops

var available_troops = []
var selected_troops = Dictionary()
var selection = null

var friendly_troops = 0
var enemies = 0

var dacian_scene = preload("res://Troops/Dacian.tscn")
var knight_scene = preload("res://Troops/knight.tscn")
var archer_scene = preload("res://Troops/archer.tscn")

signal troop_hit_signal(tribe)


func test_battle_formation():

	for i in range(0, 9):
		for j in range(1, 10):
			friendly_troops += 1

			var dacian: Troop = dacian_scene.instantiate()
			dacian.position.x = -30 + i * 8
			dacian.position.z = -40 - j * 8

			$Troops.call_deferred("add_child", dacian)

	for i in range(0, 9):
		for j in range(1, 10):
			friendly_troops += 1

			var dacian: Troop = dacian_scene.instantiate()
			dacian.position.x = 40 + i * 8
			dacian.position.z = -40 - j * 8

			$Troops.call_deferred("add_child", dacian)

	for i in range(0, 12):
		for j in range(1, 9):
			enemies += 1
			
			var knight: Troop = knight_scene.instantiate()
			knight.position.x = i * 8
			knight.position.z = 20 + j * 6
			knight.rotate_y(deg_to_rad(180))

			$Troops.call_deferred("add_child", knight)

	for i in range(0, 12):
		for j in range(0, 1):
			enemies += 1

			var archer: Troop = archer_scene.instantiate()
			archer.position.x = i * 8
			archer.position.z = 90 + j * 6
			archer.rotate_y(deg_to_rad(180))

			$Troops.call_deferred("add_child", archer)
#
	$MusicPlayer.play()

	$BattleUI.troops_count = friendly_troops
	$BattleUI.enemies_count = enemies


func test_battle_formation_for_web():
	
	for i in range(-2, 15):
		friendly_troops += 1
		var dacian: Troop = dacian_scene.instantiate()
		dacian.position.x = 20 + i * 6
		dacian.position.z = -10

		$Troops.call_deferred("add_child", dacian)

	for i in range(-3, 10):
		enemies += 1

		var knight: Troop = knight_scene.instantiate()
		knight.position.x = 20 + i * 6
		knight.position.z = 60
		knight.rotate_y(deg_to_rad(180))

		$Troops.call_deferred("add_child", knight)
		
	for i in range(0, 3):
		enemies += 1

		var archer: Troop = archer_scene.instantiate()
		archer.position.x = 40 + i * 4
		archer.position.z = 70
		archer.rotate_y(deg_to_rad(180))

		$Troops.call_deferred("add_child", archer)

	$MusicPlayer.play()
	
	$BattleUI.troops_count = friendly_troops
	$BattleUI.enemies_count = enemies


func test_battle():
	#for i in range(1, 40):
		#var dacian: Troop = dacian_scene.instantiate()
		#dacian.position.x = i * 3
		#dacian.position.z = -50 - randi_range(5, 10)
		#
		#$Troops.call_deferred("add_child", dacian)
	for i in range(1, 20):
		var knight: Troop = knight_scene.instantiate()
		knight.position.x = i * 2
		knight.position.z = 60 + randi_range(5, 10)
		knight.rotate_y(deg_to_rad(180))
		
		$Troops.call_deferred("add_child", knight)
		
	for i in range(1, 20):
		var knight: Troop = knight_scene.instantiate()
		knight.position.x = i * 2
		knight.position.z = 70 + randi_range(5, 10)
		
		$Troops.call_deferred("add_child", knight)
		
	for i in range(1, 10):
		var archer: Troop = archer_scene.instantiate()
		archer.position.x = i * 3
		archer.position.z = -60 - randi_range(5, 10)
		
		$Troops.call_deferred("add_child", archer)

	$BattleTimer.start()
	$MusicPlayer.play()


func start_attack():
	for troop in get_node("Troops").get_children():
		troop.get_node("EnemyDetectionTimer").start()


func _ready() -> void:
	$ChangeSceneUI.fade_out()
	test_battle_formation()
	#test_battle_formation_for_web()
	multiple_selection.hide()
	troop_hit_signal.connect(_on_troop_hit)


func set_troops_destination(destination):
	for troop in selected_troops:
		if troop == null or troop.is_queued_for_deletion():
			continue
		#print(troop)
		#troop.commanded_destination = destination
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
	return not troop.to_be_freed


func _on_battle_finish_timer_timeout() -> void:
	$ChangeSceneUI.change_scene()


func finish_battle(tribe_won=''):
	for troop in troops.get_children():
		if is_instance_valid(troop) and troop.tribe == tribe_won and not troop.to_be_freed:
			troop.battle_cheer()

	$MusicPlayer.stop()
	$BattleFinishTimer.start()


func _on_troop_hit(tribe) -> void:
	if tribe == 'Dacian':
		friendly_troops -= 1
	else:
		enemies -= 1

	if friendly_troops == 0:
		$BattleUI.show_lose()
		$BattleLost.play(1)
		finish_battle('Romans')
	elif enemies == 0:
		$BattleUI.show_win()
		$BattleWon.play(1)
		finish_battle('Dacian')

	$BattleUI.update(friendly_troops, enemies)
