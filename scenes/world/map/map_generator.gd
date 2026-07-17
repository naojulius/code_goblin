@tool
extends Node2D

@onready var tile_map_layer: TileMapLayer = $Tiles/TileMapLayer
@onready var detail_map_layer: TileMapLayer = $Tiles/DetailMapLayer
@onready var tree_container: Node = $TreeContainer

# --- RÉFÉRENCE À LA CAMÉRA ---
@onready var camera_2d: Camera2D = $Camera2D

@export_group("Actions")
@export_tool_button("Générer la carte") var GenerateMap = generate_procedural_map

@export_group("Map Settings")
@export var map_width: int = 520
@export var map_height: int = 520

# --- PARAMÈTRES DU BRUIT (NOISE) ---
@export_group("Noise Settings")
## Graine pour la génération de la carte. Changez ce nombre pour générer une carte totalement différente !
@export var noise_seed: int = 0
## Fréquence du bruit. Une valeur plus petite (ex: 0.01) créera de grands continents, une valeur plus grande (ex: 0.08) créera beaucoup de petites îles.
@export_range(0.001, 0.2, 0.001) var noise_frequency: float = 0.01
@export var noise: FastNoiseLite

# --- CONFIGURATION DES ARBRES ---
@export_group("Decorations Settings")
# Glissez-déposez votre scène d'arbre (.tscn) ici dans l'Inspecteur
@export var tree_scene: PackedScene 
# Définissez ici la taille occupée par un arbre (ex: 2 pour un carré 2x2, 4 pour 4x4, 8 pour 8x8)
@export_range(1, 8, 1) var tree_cell_size: int = 2
@export_range(1, 8, 1) var rock_cell_size: int = 8


# --- 4 LEVELS OF SEA ---
const WATER_DEEP_4_SOURCE: int = 0
const WATER_DEEP_4_COORDS: Vector2i = Vector2i(4, 0)

const WATER_DEEP_3_SOURCE: int = 0
const WATER_DEEP_3_COORDS: Vector2i = Vector2i(3, 0)

const WATER_DEEP_2_SOURCE: int = 0
const WATER_DEEP_2_COORDS: Vector2i = Vector2i(2, 0)

const WATER_DEEP_1_SOURCE: int = 0
const WATER_DEEP_1_COORDS: Vector2i = Vector2i(1, 0)

# --- LAND TERRAINS ---
const SAND_SOURCE: int = 0
const SAND_COORDS: Vector2i = Vector2i(0, 0)

const GRASS_SOURCE: int = 2
const GRASS_COORDS: Vector2i = Vector2i(1, 1)

# --- GRASS DETAILS ---
const DETAIL_SOURCE: int = 0
const DETAIL_1_COORDS: Vector2i = Vector2i(2, 1)
const DETAIL_2_COORDS: Vector2i = Vector2i(1, 1)

# Dictionnaire pour garder en mémoire les cellules réservées par les arbres
var reserved_cells: Dictionary = {}

func _ready() -> void:
	# Initialisation et configuration du Noise avec les variables exportées
	if not noise:
		noise = FastNoiseLite.new()
	
	noise.noise_type = FastNoiseLite.TYPE_SIMPLEX
	noise.seed = noise_seed
	noise.frequency = noise_frequency
	
	generate_procedural_map()
	center_camera_on_map()

func generate_procedural_map() -> void:
	# Sécurité si exécuté depuis l'éditeur
	if not tile_map_layer or not detail_map_layer or not tree_container:
		return
		
	tile_map_layer.clear()
	detail_map_layer.clear()
	reserved_cells.clear()
	
	# On nettoie les anciens arbres
	for child in tree_container.get_children():
		child.queue_free()
	
	# Calcul des demi-dimensions (on utilise floori pour éviter les warnings)
	var half_w: int = floori(map_width / 2.0)
	var half_h: int = floori(map_height / 2.0)
	
	# --- ÉTAPE 1 : Génération du sol de -half à +half (le centre sera en 0,0) ---
	for x in range(-half_w, half_w):
		for y in range(-half_h, half_h):
			var noise_val: float = noise.get_noise_2d(float(x), float(y))
			
			var target_source: int
			var target_coords: Vector2i
			
			if noise_val < -0.6:
				target_source = WATER_DEEP_4_SOURCE
				target_coords = WATER_DEEP_4_COORDS
			elif noise_val < -0.45:
				target_source = WATER_DEEP_3_SOURCE
				target_coords = WATER_DEEP_3_COORDS
			elif noise_val < -0.3:
				target_source = WATER_DEEP_2_SOURCE
				target_coords = WATER_DEEP_2_COORDS
			elif noise_val < -0.15:
				target_source = WATER_DEEP_1_SOURCE
				target_coords = WATER_DEEP_1_COORDS
			elif noise_val < 0.0:
				target_source = SAND_SOURCE
				target_coords = SAND_COORDS
			else:
				target_source = GRASS_SOURCE
				target_coords = GRASS_COORDS
			
			tile_map_layer.set_cell(Vector2i(x, y), target_source, target_coords)
	
	# --- ÉTAPE 2 : Placement des décors et des grands arbres ---
	for x in range(-half_w, half_w - (tree_cell_size - 1)):
		for y in range(-half_h, half_h - (tree_cell_size - 1)):
			
			var current_pos := Vector2i(x, y)
			if reserved_cells.has(current_pos):
				continue
			
			# L'arbre ne peut pousser que si TOUT son carré d'herbe est valide (pas d'eau ni de sable)
			var can_spawn_tree: bool = true
			for ox in range(tree_cell_size):
				for oy in range(tree_cell_size):
					var check_pos := Vector2i(x + ox, y + oy)
					var cell_source = tile_map_layer.get_cell_source_id(check_pos)
					if reserved_cells.has(check_pos) or cell_source != GRASS_SOURCE:
						can_spawn_tree = false
						break
				if not can_spawn_tree:
					break
			
			if can_spawn_tree:
				if tree_scene:
					var t_noise: float = noise.get_noise_2d(float(x) + 10000.0, float(y) + 10000.0)
					
					# Seuil de densité de la forêt
					if t_noise > 0.45:
						var offset_x: float = noise.get_noise_2d(float(x) + 20000.0, float(y) + 20000.0)
						var offset_y: float = noise.get_noise_2d(float(x) + 30000.0, float(y) + 30000.0)
						
						spawn_tree(current_pos, offset_x, offset_y)
						
						for ox in range(tree_cell_size):
							for oy in range(tree_cell_size):
								reserved_cells[Vector2i(x + ox, y + oy)] = true
						continue
						
			
			
			# --- SI PAS D'ARBRE, ON TENTE DE METTRE DES PETITS DÉTAILS D'HERBE ---
			if tile_map_layer.get_cell_source_id(current_pos) == GRASS_SOURCE and not reserved_cells.has(current_pos):
				var d_noise: float = noise.get_noise_2d(float(x) + 5000.0, float(y) + 5000.0)
				if d_noise > 0.4:
					var detail_coords: Vector2i = DETAIL_2_COORDS if d_noise > 0.7 else DETAIL_1_COORDS
					detail_map_layer.set_cell(current_pos, DETAIL_SOURCE, detail_coords)

func spawn_tree(grid_pos: Vector2i, offset_x: float, offset_y: float) -> void:
	if not tree_scene:
		return
		
	var tree_instance = tree_scene.instantiate()
	
	var tile_size: float = 32.0 
	var center_offset := Vector2(
		(tree_cell_size - 1) * tile_size * 0.5,
		(tree_cell_size - 1) * tile_size * 0.5
	)
	
	var base_position: Vector2 = tile_map_layer.map_to_local(grid_pos) + center_offset
	
	# Espacement aléatoire déterministe
	var max_offset: float = tile_size * 0.2
	var final_offset := Vector2(offset_x * max_offset, offset_y * max_offset)
	
	tree_instance.position = base_position + final_offset
	
	# Mise à l'échelle proportionnelle à la taille occupée
	var base_scale: float = float(tree_cell_size)
	var scale_variation: float = base_scale + (offset_x * (base_scale * 0.1))
	tree_instance.scale = Vector2(scale_variation, scale_variation)
	
	# Légère inclinaison
	tree_instance.rotation = offset_y * 0.12
	
	tree_container.add_child(tree_instance)

# --- FONCTION POUR CENTRER LA CAMÉRA ---
func center_camera_on_map() -> void:
	if camera_2d:
		# Puisque la carte est générée tout autour de Vector2i(0, 0),
		# le centre mathématique parfait de la carte est maintenant en (0, 0) !
		camera_2d.global_position = tile_map_layer.map_to_local(Vector2i.ZERO)
