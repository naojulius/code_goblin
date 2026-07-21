class_name Ressources
extends Node2D
const LABEL_NODE = preload("uid://c6h05mcme6owb")
var animation_player: AnimationPlayer = null


const MAX_CAPACITY: int = 50
var current_capacity: int = MAX_CAPACITY
func _ready() -> void:
	animation_player = get_node_or_null("AnimationPlayer")

func gather(capacity: int = 5):
	current_capacity -= capacity
	if animation_player and not animation_player.is_playing():
		animation_player.play("hit")
	

func _process(_delta: float) -> void:
	current_capacity = clamp(current_capacity, 0, MAX_CAPACITY)
