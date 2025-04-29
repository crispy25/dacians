extends Control


@export var next_scene: PackedScene = null


func fade_out():
	$AnimationPlayer.play("fade_out")


func change_scene():
	$AnimationPlayer.play("change_scene")


func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	if anim_name == "change_scene":
		get_tree().change_scene_to_packed(next_scene)
