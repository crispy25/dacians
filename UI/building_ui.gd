extends Control


func _ready() -> void:
	$ChangeSceneUI.fade_out()


func _on_back_button_pressed() -> void:
	$ChangeSceneUI.change_scene()
