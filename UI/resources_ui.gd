extends Control

const MAX_RESOURCE_VALUE = 256.0

@onready var gold_progress_bar: ProgressBar = $ProgressBars/GoldProgressBar
@onready var iron_progress_bar: ProgressBar = $ProgressBars/IronProgressBar
@onready var stone_progress_bar: ProgressBar = $ProgressBars/StoneProgressBar
@onready var wood_progress_bar: ProgressBar = $ProgressBars/WoodProgressBar
@onready var gold_quantity_label: Label = $ProgressBars/GoldProgressBar/QuantityLabel
@onready var iron_quantity_label: Label = $ProgressBars/IronProgressBar/QuantityLabel
@onready var stone_quantity_label: Label = $ProgressBars/StoneProgressBar/QuantityLabel
@onready var wood_quantity_label: Label = $ProgressBars/WoodProgressBar/QuantityLabel


var resources = {"gold": 0, "iron": 0, "stone": 0, "wood": 0}

func  _ready() -> void:
	update_resource("gold", 20)
	update_resource("iron", 100)
	update_resource("stone", 100)
	update_resource("wood", 100)



func get_resource_percentage(value):
	return value / MAX_RESOURCE_VALUE * 100


func update_resource(type, value):
	resources[type] = value

	match type:
		"gold":
			gold_progress_bar.value = get_resource_percentage(value)
			gold_quantity_label.text = str(value)
		"iron":
			iron_progress_bar.value = get_resource_percentage(value)
			iron_quantity_label.text = str(value)
		"stone":
			stone_progress_bar.value = get_resource_percentage(value)
			stone_quantity_label.text = str(value)
		"wood":
			wood_progress_bar.value = get_resource_percentage(value)
			wood_quantity_label.text = str(value)


func has_resources(resourced_needed):
	for key in resourced_needed:
		if resources[key] < resourced_needed[key]:
			return false
	
	return true


func remove_resources(resourced_needed):
	for key in resourced_needed:
		update_resource(key, resources[key] - resourced_needed[key])
