extends Node

var gold: int = 0
var wood: int = 0
var stone: int = 0
var population: int = 0

func _process(_delta: float) -> void:
	population = get_tree().get_node_count_in_group("populations")
