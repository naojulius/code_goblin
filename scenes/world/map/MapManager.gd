extends Node

signal map_changed(map: Map)

var maps: Array[Map] = [
	preload("uid://2gi0g0qrdq2v"),
	preload("uid://cowan2c0ghdco"),
	preload("uid://b6li2ha8vu1h7")
]

var current_map: Map = maps[0]
var current_map_index: int = 0

func _ready() -> void:
	_update_map_data()
	
func next_map():
	if current_map_index < maps.size() -1:
		current_map_index += 1
		_update_map_data()
		
func prev_map():
	if current_map_index > 0:
		current_map_index -= 1
		_update_map_data()

func _update_map_data():
	map_changed.emit(maps[current_map_index])
