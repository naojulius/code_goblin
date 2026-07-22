extends Sprite2D

func _ready() -> void:
	# Changer la couleur en bleu
	set_color(GameManager.my_unit_color)

## Fonction pour modifier la couleur du shader dynamiquement
func set_color(new_color: Color) -> void:
	if material is ShaderMaterial:
		material.set_shader_parameter("target_color", new_color)
