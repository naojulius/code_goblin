extends Building

func _ready() -> void:
	add_to_group("inns")

#add label ex: "wood +1"  on the buiding
func add_label(text: String, _pos: Vector2):
	var label_node: Node2D = LABEL_NODE.instantiate()
	add_child(label_node)
	label_node.setup(text, _pos)
