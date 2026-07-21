extends Control

@onready var command_grid_container: HBoxContainer = $Panel/MarginContainer/Panel/HBoxContainer/MarginContainer/CommandContainerPanel/CommandGridContainer
@onready var avatar_panel: MarginContainer = $Panel/MarginContainer/Panel/HBoxContainer/AvatarPanel

# On garde une copie locale des commandes actuellement affichées
var displayed_command: Command = null 

func _ready() -> void:
	add_to_group("panel_managers")
	
func _process(_delta: float) -> void:
	# Comparaison propre du contenu des deux tableaux
	if displayed_command != PanelManager.current_command:
		_update_command_grid()
		

func _update_command_grid() -> void:
	# 1. On vide proprement l'ancienne grille
	for child in command_grid_container.get_children():
		child.queue_free()
		
	for child in avatar_panel.get_children():
		child.queue_free()
	
	# 2. On instancie les nouvelles commandes
	if PanelManager.current_command and PanelManager.current_command.commands:
		for packed_scene in PanelManager.current_command.commands:
			if packed_scene != null: # Sécurité si une case du tableau est vide
				var command: MarginContainer = packed_scene.instantiate()
				command.connect("pressed", _on_pressed_command.bind(PanelManager.current_command.unit))
				command_grid_container.add_child(command)
				
		var avatar: Panel = PanelManager.current_command.avatar.instantiate()
		avatar_panel.add_child(avatar)
	
	# 3. On synchronise notre copie locale pour bloquer le prochain passage dans _process
	displayed_command = PanelManager.current_command
	
func _on_pressed_command(command_name: String, unit):
	match command_name:
		"code_command":
			if unit.has_method("show_editor"):
				unit.show_editor()
	#pass
