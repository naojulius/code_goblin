@tool
extends Control

const BUTTON_PANEL = preload("uid://es1d2w448ria")
const FREQ_MIN: float = 0.0   # Plage modifiée pour capter la mélodie Chiptune
const FREQ_MAX: float = 400.0

@onready var button_box_container: VBoxContainer = $ButtonBoxContainer
@onready var audio_player: AudioStreamPlayer = $Sounds/BackgroundAudioPlayer
@onready var title_label: RichTextLabel = $TitleLabel

var spectrum_analyzer: AudioEffectInstance

const menu_buttons: Array = [
	{"button_text": "Single Player"},
	{"button_text": "Online"},
	{"button_text": "Local multiplayer"},
	{"button_text": "Options"},
	{"button_text": "Credits"},
	{"button_text": "exit"}
]

func _ready() -> void:
	# 1. Initialisation de l'analyseur audio uniquement au runtime (pas dans l'éditeur)
	if not Engine.is_editor_hint():
		_setup_audio_spectrum()

	# 2. Régénération des boutons du menu
	for child in button_box_container.get_children():
		child.queue_free()
	
	for button_info in menu_buttons:
		var button_panel: Panel = BUTTON_PANEL.instantiate()
		var button: Button = button_panel.get_node_or_null("Button")
		
		if button:
			button.name = to_pascal_case(str(button_info.button_text, " Button"))
			button.text = str(button_info.button_text)
			
			# Connexion moderne des signaux Godot 4
			button.mouse_entered.connect(_on_button_mouse_entered.bind(button_panel, button.name))
			button.mouse_exited.connect(_on_button_mouse_exited.bind(button_panel, button.name))
			
		button_box_container.add_child(button_panel)


func _process(_delta: float) -> void:
	# Ignore l'exécution dans l'éditeur et s'assure que le son tourne
	if Engine.is_editor_hint():
		return
		
	if spectrum_analyzer == null or audio_player == null or not audio_player.playing:
		return
		
	# Calcul de l'intensité audio
	var magnitude: Vector2 = spectrum_analyzer.get_magnitude_for_frequency_range(FREQ_MIN, FREQ_MAX)
	var intensity: float = clamp(magnitude.length() * 35.0, 0.0, 1.0) # Ajusté à 35.0 et clamp à 1.0
	
	# Réaction des effets BBCode au rythme
	var shake_rate = remap(intensity, 0.0, 1.0, 5.0, 50.0)
	var shake_level = remap(intensity, 0.0, 1.0, 0.0, 20.0)
	
	if title_label:
		title_label.text = "{ [shake rate=%.1f level=%.1f][b]Code Craft[/b][/shake] }" % [shake_rate, shake_level]


func _setup_audio_spectrum() -> void:
	var bus_index = AudioServer.get_bus_index("Master")
	
	if AudioServer.get_bus_effect_count(bus_index) > 0:
		var effect = AudioServer.get_bus_effect(bus_index, 0)
		if effect is AudioEffectSpectrumAnalyzer:
			spectrum_analyzer = AudioServer.get_bus_effect_instance(bus_index, 0)
			print("Spectrum Analyzer ready on Master bus.")
		else:
			push_error("Effect at index 0 is not an AudioEffectSpectrumAnalyzer.")
	else:
		push_error("No audio effect found on Master bus. Add AudioEffectSpectrumAnalyzer to Master bus.")


func _on_button_mouse_entered(button_panel: Panel, button_name: String) -> void:
	print("entered: ", button_name)

func _on_button_mouse_exited(button_panel: Panel, button_name: String) -> void:
	print("exit: ", button_name)

func to_pascal_case(text: String) -> String:
	var words = text.split(" ")
	var result := ""
	for word in words:
		result += word.capitalize()
	return result
