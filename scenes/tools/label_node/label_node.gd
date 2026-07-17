extends Node2D
@onready var animation_player: AnimationPlayer = $Transformnode/AnimationPlayer
@onready var label: Label = $Transformnode/Label

var speed: float = 20.0
func _ready() -> void:
	top_level = true
	animation_player.connect("animation_finished", anim_finished)
	label.z_index = 50
	
func anim_finished(anim_name: String):
	if anim_name.contains("show"):
		queue_free()

func _process(delta: float) -> void:
	if is_instance_valid(self):
		position.y -= delta * speed

func setup(text: String, _pos: Vector2):
	global_position = _pos
	label.text = str(text)
