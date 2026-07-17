# Dans tree.gd
extends Ressources

@onready var sprite_node_cut: Node2D = $SpriteNode_Cut
@onready var sprite_node_intact: Node2D = $SpriteNode_Intact

var trunk_showed: bool = false
var group_name: String = "wood"

func _ready() -> void:
	add_to_group(group_name)

func _process(_delta: float) -> void:
	if current_capacity <= 0 and not trunk_showed:
		trunk_showed = true
		sprite_node_intact.hide()
		sprite_node_cut.show()
		
		# Sécurité : On retire immédiatement de TOUS les groupes pour qu'aucun paysan ne le cible
		remove_from_group(group_name)
		if is_in_group("wood"):
			remove_from_group("wood")
		await get_tree().create_timer(3.0).timeout
		queue_free()
		

func add_label(text: String, _pos):
	var label_node: Node2D = LABEL_NODE.instantiate()
	add_child(label_node)
	label_node.setup(text, _pos)
