extends Node2D


@onready var yes_sound_effect = $YesSoundEffect
@onready var no_sound_effect = $NoSoundEffect

var selected_zone = null


func _input(event: InputEvent) -> void:
	if event.is_action_released("select") and selected_zone:
		if not selected_zone.locked:
			$YesSoundEffect.play(2)
			var next_scene = selected_zone.scene
	
			var tween = get_tree().create_tween()
			tween.tween_property($Camera2D, "position", selected_zone.position, 0.8)
			tween.tween_property($Camera2D, "zoom", Vector2(30, 30), 1.5)
			tween.parallel().tween_property($Camera2D/PointLight2D, "energy", 0, 0.7)
			tween.parallel().tween_property($Music, "volume_db", -40, 0.7)
			await tween.finished

			get_tree().change_scene_to_file(next_scene)
		else:
			$NoSoundEffect.play(2.1)
