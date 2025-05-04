extends Control

@onready var resources_ui: Control = $ResourcesUI
@onready var building_selection_ui: Control = $BuildingSelectionUI
@onready var toggle_ui_button: Button = $BuildingSelectionUI/ToggleUIButton


var shown = true

func _ready() -> void:
	$ChangeSceneUI.fade_out()


func _on_back_button_pressed() -> void:
	$ChangeSceneUI.change_scene()


func _on_toggle_ui_button_pressed() -> void:
	shown = not shown
	var next_position = building_selection_ui.position

	if not shown:
		next_position.x = DisplayServer.screen_get_size()[1] - 832
		toggle_ui_button.text = "<"
	else:
		next_position.x = 0
		toggle_ui_button.text = ">"

	var tween = get_tree().create_tween()
	tween.tween_property($BuildingSelectionUI, "position", next_position, 0.4)
