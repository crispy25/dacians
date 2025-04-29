extends Area2D


@export var zone_name = "Zone"
@export var scene: String
@export var locked: bool = true
@export var texture_path: String

@onready var map = get_parent().get_parent()


func _ready() -> void:
	if texture_path:
		$Sprite2D.texture = load(texture_path)

		if texture_path == "res://Assets/attack.png":
			$Sprite2D.scale = Vector2(0.15, 0.15)
		else:
			$Sprite2D.scale = Vector2(0.4, 0.4)
			$Sprite2D.self_modulate = Color("green")
		
	$Label.text = zone_name
	

func _on_mouse_entered() -> void:
	map.selected_zone = self
	
	if locked:
		$Label.self_modulate = Color("red")
	else:
		$Label.self_modulate = Color("green")


func _on_mouse_exited() -> void:
	map.selected_zone = null
	
	$Label.self_modulate = Color(1, 1, 1, 1)
