class_name Ressources
extends Node2D

const MAX_CAPACITY: int = 10
var current_capacity: int = MAX_CAPACITY

func gather(capacity: int = 5):
	current_capacity -= capacity

func _process(_delta: float) -> void:
	current_capacity = clamp(current_capacity, 0, MAX_CAPACITY)
