extends Control

const CODE_LINE = preload("uid://cq448ycxv6i03")

# Prompt de base qu'on va formater dynamiquement
const PROMPT_TEMPLATE = "[color=#4e9a06]%s@_01[/color]:[color=#729fcf]~$ [/color]"

@onready var save_button: Button = $CodeEditorPanel/MarginContainer/VBoxContainer/Header/HBoxContainer/HBoxContainer/SaveButton
@onready var setting_button: Button = $CodeEditorPanel/MarginContainer/VBoxContainer/Header/HBoxContainer/HBoxContainer/SettingButton
@onready var exit_button: Button = $CodeEditorPanel/MarginContainer/VBoxContainer/Header/HBoxContainer/HBoxContainer/ExitButton
@onready var code_editor: TextEdit = $CodeEditorPanel/MarginContainer/VBoxContainer/TextEdit/HBoxContainer/CodeEditor
@onready var console: RichTextLabel = $CodeEditorPanel/MarginContainer/VBoxContainer/ConsolePanel/Console
@onready var file_button: Button = $CodeEditorPanel/MarginContainer/VBoxContainer/FileContent/MarginContainer/HBoxContainer/File_Button_1
@onready var line_container: VBoxContainer = $CodeEditorPanel/MarginContainer/VBoxContainer/TextEdit/HBoxContainer/LineNumberMargin/LineContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var current_unit = null
var current_prompt = "[color=#4e9a06]C_C OS[/color]:[color=#729fcf]~$ [/color]"


func _ready() -> void:
	add_to_group("code_editor")
	console.selection_enabled = false
	console.bbcode_enabled = true
	
	save_button.connect("pressed", _on_save_button_pressed)
	exit_button.connect("pressed", hide_editor)
	code_editor.connect("text_changed", update_lines)
	write_line("Code Craft OS initialized.", "success")
	update_lines()
	
var executed_first: bool = false
	
func _process(_delta: float) -> void:
	if not executed_first and current_unit:
		#_on_save_button_pressed()
		#executed_first = true
		pass
		
func _input(event: InputEvent) -> void:
	if event is InputEventKey and visible:
		if event.pressed:
			if event.ctrl_pressed and event.keycode == KEY_S:
				# On consomme l'input pour éviter que d'autres actions se déclenchent
				get_viewport().set_input_as_handled() 
				_on_save_button_pressed()
	
func show_editor():
	for code in get_tree().get_nodes_in_group("code_editor"):
		code.hide_editor()
		
	if not animation_player.is_playing() and not visible:
		animation_player.play("show")

func hide_editor():
	if not animation_player.is_playing() and visible:
		animation_player.play("hide")
	
func update_lines():
	for child in line_container.get_children():
		child.queue_free()
	
	for i in range(code_editor.get_line_count()):
		var label = CODE_LINE.instantiate()
		label.text = str(i + 1)
		line_container.add_child(label)

# --- MISE À JOUR : Sélection de l'unité avec prompt dynamique ---
func select_unit(new_unit: CharacterBody2D) -> void:
	current_unit = new_unit
	
	if current_unit:
		# 1. On adapte le Prompt au nom ou à la classe de l'unité (en minuscules)
		var unit_type = "unit"
		if current_unit is Paysant:
			unit_type = "paysant"
		# else if current_unit is Soldat: unit_type = "soldat" (facile pour le futur !)
		
		current_prompt = PROMPT_TEMPLATE % unit_type
		
		# 2. Chargement du code précédemment sauvegardé dans l'unité
		code_editor.text = current_unit.saved_code
		update_lines()
		
		write_line("Établissement de la liaison avec : " + current_unit.name, "system")
	else:
		current_prompt = PROMPT_TEMPLATE % "user"

func _on_save_button_pressed():
	var code = code_editor.text
	
	# Sécurité 1 : On vérifie qu'une unité est bien sélectionnée
	if not is_instance_valid(current_unit):
		write_line("Erreur : Aucune unité sélectionnée ou unité détruite.", "error")
		return
		
	# Sécurité 2 : On vérifie que cette unité possède bien son propre interpréteur
	if not "interpreter" in current_unit or current_unit.interpreter == null:
		write_line("Erreur : L'unité " + current_unit.name + " n'a pas d'interpréteur C#.", "error")
		return
		
	write_line("Compilation et envoi du code à " + current_unit.name + "...", "info")
	
	# Appel de l'interpréteur spécifique (qui a son propre validateur)
	var result = current_unit.interpreter.execute_code(code, current_unit)
	print(current_unit)
	# Sauvegarde du code dans l'unité pour ne pas le perdre en changeant d'unité
	current_unit.saved_code = code
	
	if result["is_valid"]:
		write_line("Code appliqué avec succès !", "success")
	else:
		# Affiche l'erreur de validation renvoyée par le validateur de l'unité
		write_line(result["error"], "error")
	
func write_line(text: String, type: String = "info") -> void:
	var color_code := "#ffffff" # Blanc par défaut
	
	match type:
		"error":
			color_code = "#ef2929" # Rouge (Erreur)
		"warning":
			color_code = "#f57900" # Orange (Alerte/Danger)
		"success":
			color_code = "#8ae234" # Vert clair (Succès)
		"info":
			color_code = "#eeeeec" # Gris clair (Information)
		"system":
			color_code = "#ad7fa8" # Violet (Système)

	# Utilisation du prompt dynamique mis à jour
	var formatted_line = "%s[color=%s]%s[/color]\n" % [current_prompt, color_code, text]
	
	console.append_text(formatted_line)
	
	# Force le défilement vers le bas
	await get_tree().process_frame
	var scrollbar = console.get_v_scroll_bar()
	if scrollbar:
		scrollbar.value = scrollbar.max_value

func log_message(text: String, type: String = "info") -> void:
	write_line(text, type)
