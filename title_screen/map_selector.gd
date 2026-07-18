extends Control

@onready var prev_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer/PrevButton
@onready var next_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer/NextButton
@onready var map_generator: Node2D = $PanelContainer/MarginContainer/VBoxContainer/MarginContainer/SubViewportContainer/SubViewport/Camera2D/MapGenerator

var min_seed: int = 0
var max_seed: int = 10
var map_seed: int = 0

func _ready() -> void:
	prev_button.connect("pressed", _prev)
	next_button.connect("pressed", _next)
	
func _prev():
	if map_seed > min_seed:
		map_seed -= 1
		update_map()
	
func _next():
	if map_seed < max_seed:
		map_seed += 1
		update_map()
		
func update_map():
	print("Generating map")
	print(map_seed)
	
	map_generator.noise_seed = map_seed
	map_generator.generate_procedural_map()
