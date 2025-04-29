extends Control


var next_scene = null


var tooltip_texts = ["Salut, dacule!", "Esti pregatit de lupta?", "100/100", "In developement..."]


func _ready() -> void:
	$AnimationPlayer.play("idle_effect")
	$TitleAnimationPlayer.play("title_effect")


func _on_play_button_pressed() -> void:
	next_scene = "res://UI/map_ui.tscn"
	$AnimationPlayer.play("change_scene")


func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	get_tree().change_scene_to_file(next_scene)


func _on_label_mouse_entered() -> void:
	tooltip_text = tooltip_texts.pick_random()
	
