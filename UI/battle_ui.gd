extends Control

@onready var scene = get_parent()
@onready var troops_node = get_parent().get_node("Troops")
@onready var toops_remaining_bar: ProgressBar = $ToopsRemaining
@onready var enemies_remaining_bar: ProgressBar = $EnemiesRemaining

@export var troops_count = 0
@export var enemies_count = 0


func is_troop_valid(troop):
	return is_instance_valid(troop) and not troop.is_queued_for_deletion() and not troop.to_be_freed


func is_friend(troop):
	return troop.tribe == 'Dacian'


func is_enemy(troop):
	return not is_friend(troop)


func update(friendly_troops, enemy_troops):
	#var all_troops = troops_node.get_children()
	#var valid_troops = all_troops.filter(is_troop_valid)
	#var troops_remaining = valid_troops.filter(is_friend).size()
	#var enemies_remaining = valid_troops.filter(is_enemy).size()
	var troops_remaining = friendly_troops
	var enemies_remaining = enemy_troops
	toops_remaining_bar.value = 1.0 * troops_remaining / troops_count * 100.0
	enemies_remaining_bar.value = 1.0 * enemies_remaining / enemies_count * 100.0


func _on_start_battle_button_pressed() -> void:
	scene.start_attack()
	$StartBattleButton.disabled = true
	$StartBattleButton.text = ''


func show_win():
	$BattleWonContainer.show()


func show_lose():
	$StartBattleButton.text = 'X'
	
