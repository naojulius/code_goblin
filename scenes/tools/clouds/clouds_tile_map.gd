@tool
extends TileMapLayer

@export var cloud_threshold: float = 0.2 # Plus haut = petits nuages, Plus bas = gros nuages

# Configuration du Tileset
@export var source_id: int = 0
@export var cloud_atlas_coords: Vector2i = Vector2i(0, 0) 
const TILE_SIZE: int = 16

var noise: FastNoiseLite
@onready var parent_control: Control = $".."


func _ready() -> void:
	# 1. Récupérer le parent Control
	parent_control = get_parent() as Control
	if not parent_control:
		push_error("Le parent doit être un Control Node !")
		return
		
	# 2. Initialiser le Noise
	noise = FastNoiseLite.new()
	noise.seed = randi()
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.07 
	noise.fractal_octaves = 3

	# 3. Générer les nuages une première fois
	generate_clouds()
	
	# 4. (Optionnel) Si le Control change de taille (ex: redimensionnement de fenêtre)
	parent_control.resized.connect(generate_clouds)

func generate_clouds() -> void:
	clear()
	
	# Calculer le nombre de tuiles nécessaires pour remplir le Control
	var map_width: int = ceil(parent_control.size.x / TILE_SIZE)
	var map_height: int = ceil(parent_control.size.y / TILE_SIZE)
	
	# Boucle de génération
	for x in range(map_width):
		for y in range(map_height):
			var noise_val = noise.get_noise_2d(x, y)
			
			if noise_val > cloud_threshold:
				set_cell(Vector2i(x, y), source_id, cloud_atlas_coords)
