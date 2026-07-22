extends Control

signal confirm_map
const SFX_MOUSE_CONFIRM_BUTTON = preload("uid://b0q5xnlnqi0k5")
const OPTION_CONTAINER = preload("uid://dtpn2tgntu8ij")

@onready var continue_button: Button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/HBoxContainer2/ContinueButton
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var button_back: Button = $PanelContainer/MarginContainer/VBoxContainer/HeadContainer/ButtonBack
@onready var button_audio_player: AudioStreamPlayer = $AudioNode/ButtonAudioPlayer
@onready var options_box_container: VBoxContainer = $PanelContainer/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/DetailsPanel/Panel/MarginContainer/OptionsBoxContainer

@onready var prev_map_button: Button = $PanelContainer/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/MapPanel/MarginContainer/Panel/ButtonsMapContainer/PrevMapPanelButtonContainer/Button
@onready var next_map_button: Button = $PanelContainer/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/MapPanel/MarginContainer/Panel/ButtonsMapContainer/NextMapPanelButtonContainer/Button

@onready var map_thumbnail_texture_rect: TextureRect = $PanelContainer/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/MapPanel/MarginContainer/TextureRect
@onready var map_name: Label = $PanelContainer/MarginContainer/VBoxContainer/MarginContainer/HBoxContainer/MapPanel/MarginContainer/Panel2/VBoxContainer/MapName
@onready var map_button_audio_player: AudioStreamPlayer = $AudioNode/MapButtonAudioPlayer


var available_slots: int = 6
var player_number: int = 0
var computer_number: int = 0

# Stocke les IDs des couleurs actuellement attribuées
var used_colors: Array[int] = []


func compute_slots():
	computer_number = available_slots - player_number

func play_show():
	if not animation_player.is_playing():
		animation_player.play("show")
		
func play_hide():
	if not animation_player.is_playing():
		animation_player.play("hide")

func _prev_map():
	MapManager.prev_map()
	map_button_audio_player.play()
	
func _next_map():
	MapManager.next_map()
	map_button_audio_player.play()

func _ready() -> void:
	prev_map_button.connect("pressed", _prev_map)
	next_map_button.connect("pressed", _next_map)
	MapManager.connect("map_changed", _on_map_changed)
	_on_map_changed(MapManager.current_map)
	
	compute_slots()
	button_back.connect("pressed", _on_button_back_pressed)
	continue_button.connect("pressed", _on_confirm_map)
	
	for i in options_box_container.get_children():
		i.queue_free()
		
	for id in range(available_slots):
		var _option = OPTION_CONTAINER.instantiate()
		options_box_container.add_child(_option)
		var _owner: String = ""
		if id <= player_number:
			if id == 0:
				_owner = "YOU"
				_option.label.text = _owner
				_option.option_button.disabled = false
			else:
				_owner = str("PLAYER ", id)
				_option.label.text = _owner
				_option.option_button.disabled = true
		else:
			_owner = str("COMPUTER ", id)
			_option.label.text = _owner
			_option.option_button.disabled = false

		# Attribue une couleur unique à cette option
		_get_unique_color(_option, _owner)
		
		# Connexion du signal pour gérer les changements manuels de couleur
		_option.connect("color_changed", _on_option_color_changed.bind(_owner))

func _get_unique_color(option, _owner) -> void:
	var color_data = option.get_random_color()
	
	# Tant que la couleur piochée est déjà dans used_colors, on en repioche une autre
	# (Sécurité pour éviter une boucle infinie si plus de slots que de couleurs)
	var attempts = 0
	while used_colors.has(color_data["id"]) and attempts < 50:
		color_data = option.get_random_color()
		attempts += 1
	
	# Applique les données et enregistre l'ID de la couleur comme utilisée
	option.set_option_data(color_data, _owner)
	used_colors.append(color_data["id"])

func _on_option_color_changed(color_data: Dictionary, option, _owner) -> void:
	var new_id: int = color_data["id"]
	var old_id: int = option.current_color_id
	
	# Si le joueur a cliqué sur la couleur qu'il a DÉJÀ : on ne fait rien
	if new_id == old_id:
		return

	# Si la couleur est libre
	if not used_colors.has(new_id):
		# 1. On libère l'ancienne couleur du joueur
		if old_id != -1:
			used_colors.erase(old_id)
			
		# 2. On applique et réserve la nouvelle
		option.set_option_data(color_data, _owner)
		used_colors.append(new_id)
	else:
		# Couleur déjà prise : on force le menu à revenir à l'ancien texte/sélection
		print("Another player has this color!")
		option.revert_selection()

func _on_button_back_pressed():
	button_audio_player.stream = SFX_MOUSE_CONFIRM_BUTTON
	if not button_audio_player.is_playing():
		button_audio_player.play()
	
	for _existing_button in get_tree().get_nodes_in_group("ui_buttons"):
		_existing_button.disabled = false
	
	play_hide()

func _on_confirm_map():
	confirm_map.emit()

func _on_map_changed(map: Map):
	map_thumbnail_texture_rect.texture = load(map.map_thumbnail)
	map_name.text = str(map.map_name)
