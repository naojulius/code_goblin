@tool
extends Control

@export var scroll_speed: float = 30.0 # Vitesse en pixels par seconde
@export var cloud_threshold: float = 0.2

# Configuration du Tileset (Ajuste selon ton inspecteur)
@export var source_id: int = 0
@export var cloud_atlas_coords: Vector2i = Vector2i(0, 0)

const TILE_SIZE: int = 16

var noise: FastNoiseLite
var current_scroll: float = 0.0
# Variable pour stocker le décalage en nombre de tuiles
var tile_offset_x: int = 0 

@onready var tilemap_layer: TileMapLayer = $CloudsTileMap

func _ready() -> void:
	# 1. Configuration du masque pour ne pas que les nuages dépassent du Control
	clip_contents = true 
	
	# 2. Initialiser le Noise
	noise = FastNoiseLite.new()
	# Si on est en mode @tool, randi() change à chaque sauvegarde. On peut fixer un seed ou le laisser.
	if not Engine.is_editor_hint():
		noise.seed = randi()
	else:
		noise.seed = 12345
		
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.frequency = 0.07
	noise.fractal_octaves = 3

	# 3. Générer et connecter le signal de redimensionnement
	generate_clouds()
	resized.connect(generate_clouds)

func generate_clouds() -> void:
	if not tilemap_layer: return
	
	tilemap_layer.clear()
	
	# +2 de largeur pour avoir des tuiles "tampons" cachées à droite pendant le scroll
	var map_width: int = ceil(size.x / TILE_SIZE) + 2
	var map_height: int = ceil(size.y / TILE_SIZE)
	
	for x in range(map_width):
		for y in range(map_height):
			# Crucial : On ajoute tile_offset_x pour charger la suite du bruit
			var noise_val = noise.get_noise_2d(x + tile_offset_x, y)
			if noise_val > cloud_threshold:
				tilemap_layer.set_cell(Vector2i(x, y), source_id, cloud_atlas_coords)

func _process(delta: float) -> void:
	if not tilemap_layer: return
	
	# 1. On fait avancer le compteur de défilement
	current_scroll += scroll_speed * delta
	
	# 2. On calcule combien de tuiles complètes ont défilé
	var new_tile_offset: int = floor(current_scroll / TILE_SIZE)
	
	# 3. Si on a avancé d'une tuile entière, on régénère le TileMap avec le nouveau décalage
	if new_tile_offset != tile_offset_x:
		tile_offset_x = new_tile_offset
		generate_clouds()
	
	# 4. On applique le sous-mouvement fluide (0 à -16px) au TileMapLayer enfant
	tilemap_layer.position.x = -fmod(current_scroll, TILE_SIZE)
