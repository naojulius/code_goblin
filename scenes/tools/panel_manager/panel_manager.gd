extends Control

@onready var command_grid_container: HBoxContainer = $Panel/MarginContainer/Panel/HBoxContainer/MarginContainer/CommandContainerPanel/CommandGridContainer

# On garde une copie locale des commandes actuellement affichées
var displayed_commands: Array[PackedScene] = [] 

func _ready() -> void:
	add_to_group("panel_managers")
	
func _process(_delta: float) -> void:
	# Comparaison propre du contenu des deux tableaux
	if displayed_commands != PanelManager.current_commands:
		_update_command_grid()
		

func _update_command_grid() -> void:
	# 1. On vide proprement l'ancienne grille
	for child in command_grid_container.get_children():
		child.queue_free()
	
	# 2. On instancie les nouvelles commandes
	for packed_scene in PanelManager.current_commands:
		if packed_scene != null: # Sécurité si une case du tableau est vide
			var command: MarginContainer = packed_scene.instantiate()
			command_grid_container.add_child(command)
	
	# 3. On synchronise notre copie locale pour bloquer le prochain passage dans _process
	displayed_commands = PanelManager.current_commands.duplicate()
