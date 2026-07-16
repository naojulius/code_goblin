extends Panel
const CODE_LINE = preload("uid://cq448ycxv6i03")
const PROMPT = "[color=#4e9a06]paysant@_01[/color]:[color=#729fcf]~$ [/color]"

# L'unité actuellement contrôlée par cet éditeur
@export var current_unit: CharacterBody2D 

@onready var save_button: Button = $MarginContainer/VBoxContainer/Header/HBoxContainer/HBoxContainer/SaveButton
@onready var setting_button: Button = $MarginContainer/VBoxContainer/Header/HBoxContainer/HBoxContainer/SettingButton
@onready var exit_button: Button = $MarginContainer/VBoxContainer/Header/HBoxContainer/HBoxContainer/ExitButton
@onready var text_edit: TextEdit = $MarginContainer/VBoxContainer/TextEdit/HBoxContainer/TextEdit
@onready var console_output: RichTextLabel = $MarginContainer/VBoxContainer/Console/ConsoleOutput
@onready var line_container: VBoxContainer = $MarginContainer/VBoxContainer/TextEdit/HBoxContainer/LineNumberMargin/LineContainer
@onready var animation_player: AnimationPlayer = $AnimationPlayer


func _ready() -> void:
	add_to_group("code_editor")
	console_output.selection_enabled = false
	console_output.bbcode_enabled = true
	
	save_button.connect("pressed", _on_save_button_pressed)
	exit_button.connect("pressed", hide_editor)
	text_edit.connect("text_changed", update_lines)
	
	write_line("Système d'initialisation de l'éditeur démarré...", "success")
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
	
	for i in range(text_edit.get_line_count()):
		var label = CODE_LINE.instantiate()
		label.text = str(i + 1)
		line_container.add_child(label)

# --- NOUVELLE FONCTION : Pour changer de paysan à la volée ---
func select_unit(new_unit: CharacterBody2D) -> void:
	current_unit = new_unit
	
	# Optionnel : Si tu stockes le code dans chaque paysan, on le charge ici
	if current_unit and "saved_code" in current_unit:
		text_edit.text = current_unit.saved_code
		update_lines()
		
	write_line("Connecté à l'unité : " + current_unit.name, "system")

func _on_save_button_pressed():
	var code = text_edit.text
	
	# Sécurité 1 : On vérifie qu'une unité est bien sélectionnée
	if not is_instance_valid(current_unit):
		write_line("Erreur : Aucune unité sélectionnée ou unité détruite.", "error")
		return
		
	# Sécurité 2 : On vérifie que cette unité possède bien son propre interpréteur
	if not "interpreter" in current_unit or current_unit.interpreter == null:
		write_line("Erreur : L'unité " + current_unit.name + " n'a pas d'interpréteur C#.", "error")
		return
		
	write_line("Compilation et envoi du code à " + current_unit.name + "...", "info")
	
	# --- APPEL DE L'INTERPRÉTEUR LOCAL DU PAYSAN ---
	var result = current_unit.interpreter.execute_code(code, current_unit)
	
	# Sauvegarde du code dans l'unité pour ne pas le perdre en changeant de paysan
	if "saved_code" in current_unit:
		current_unit.saved_code = code
	
	if result["is_valid"]:
		write_line("Code appliqué avec succès sur " + current_unit.name + " !", "success")
	else:
		# Affiche l'erreur proprement dans ta console Linux
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

	# Construction de la ligne : Prompt ($) + Message coloré
	var formatted_line = "%s[color=%s]%s[/color]\n" % [PROMPT, color_code, text]
	
	# Ajout du texte
	console_output.append_text(formatted_line)
	
	# --- FORCE LE DÉFILEMENT VERS LE BAS ---
	await get_tree().process_frame
	var scrollbar = console_output.get_v_scroll_bar()
	if scrollbar:
		scrollbar.value = scrollbar.max_value

func log_message(text: String, type: String = "info") -> void:
	write_line(text, type)
