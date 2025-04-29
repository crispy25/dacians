extends TextureButton

@export var building_scene: PackedScene
@export var building_name: String
@export var resources_required: String

@onready var base = get_tree().get_root().get_child(0)
@onready var buildings = base.get_child(0)


func _ready() -> void:
	$Name.text = building_name
	$ResourcesRequired.text = resources_required


func _on_pressed() -> void:
	var building = building_scene.instantiate()
	#building.position = base.selected_position
	building.position.y = 0
	building.scale = Vector3.ONE * 15
	buildings.call_deferred("add_child", building)
	
	base.current_building = building
