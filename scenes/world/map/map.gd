extends Node2D

const INN_A = preload("uid://fj2hnyk1cvux")
const PAYSANT = preload("uid://cdeimvkxpfwjc")
const PAYSANT_NUMBER: int = 1

@onready var base_markers: Node2D = $BaseMarkers
@onready var buildings: Node2D = $Buildings
@onready var units: Node2D = $Units


# Store the actual Marker2D nodes so we can check/set properties on them
var bases: Array[Node] = []
var player_ids: Array[int] = [1]

func _ready() -> void:
	# Use get_children() to iterate through the markers
	for marker in base_markers.get_children():
		bases.append(marker)
		# Dynamically add an 'is_occupied' property to the marker if it doesn't have one
		marker.set_meta("is_occupied", false)
	
	# Call the function to test it
	place_base()

func place_base() -> void:
	for player in player_ids:
		# Find the first available (unoccupied) base
		var target_base: Marker2D = null
		for base in bases:
			if not base.get_meta("is_occupied", false):
				target_base = base
				break # Found one, stop looking
		
		# If we found a free base, instantiate and place the inn
		if target_base != null:
			var inn: Node2D = INN_A.instantiate()
			
			inn.name = str("Inn_", player)
			buildings.add_child(inn)
			
			for p in PAYSANT_NUMBER:
				var paysant: CharacterBody2D = PAYSANT.instantiate()
				units.add_child(paysant)
				paysant.global_position = target_base.get_child(0).global_position
			
			inn.global_position = target_base.global_position
			target_base.set_meta("is_occupied", true)
			
		else:
			push_warning("Not enough empty bases for player: ", player)
