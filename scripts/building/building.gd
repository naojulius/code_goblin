class_name Building
extends Node2D
const LABEL_NODE = preload("uid://c6h05mcme6owb")

@onready var sensor_area: Area2D = $SensorArea
@onready var box_selector: Node2D = $BoxSelector
var is_unit_selected: bool = false


var building_name: String = ""
func _ready() -> void:
	sensor_area.connect("input_event", _on_sensor_area_input_event)

func _on_sensor_area_input_event(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			box_selector.show_box_selector()
			is_unit_selected = true

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("MOUSE_LEFT") and is_unit_selected:
		box_selector.hide_box_selector()
		is_unit_selected = false
