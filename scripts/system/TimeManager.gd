extends Node

# --- Signaux (Super pratiques pour synchroniser les lumières/UI de ton RTS) ---
signal hour_changed(current_hour: int)
signal day_changed(day_count: int)

# --- Configuration du temps ---
@export var day_duration_seconds: float = 1800.0 # Durée d'une journée complète en secondes réelles 30minute

# Variables de temps réelles
var time_in_seconds: float = 0.0
var days_passed: int = 1

# Getters pratiques pour la logique de jeu
var hour: int:
	get: return int(time_in_seconds / 3600.0) % 24

var minute: int:
	get: return int(time_in_seconds / 60.0) % 60

var second: int:
	get: return int(time_in_seconds) % 60

var _last_emitted_hour: int = -1


func _ready() -> void:
	# Génère une heure de départ aléatoire (en secondes entre 0h00 et 23h59)
	# time_in_seconds va de 0.0 à 86400.0 (24 * 3600)
	time_in_seconds = randf_range(0.0, 86400.0)
	
	_last_emitted_hour = hour
	print("Heure de départ générée : ", get_time_formatted_24h())


func _process(delta: float) -> void:
	# Vitesse du temps : 86400 secondes de jeu divisées par la durée réelle voulue
	var time_factor: float = 86400.0 / day_duration_seconds
	time_in_seconds += delta * time_factor

	# Gestion du changement de jour
	if time_in_seconds >= 86400.0:
		time_in_seconds -= 86400.0
		days_passed += 1
		day_changed.emit(days_passed)

	# Signal quand une heure complète passe
	if hour != _last_emitted_hour:
		_last_emitted_hour = hour
		hour_changed.emit(hour)

## Retourne le temps au format 24h (ex: "14:05" ou "08:30")
func get_time_formatted_24h(include_seconds: bool = false) -> String:
	if include_seconds:
		return "%02d:%02d:%02d" % [hour, minute, second]
	return "%02d:%02d" % [hour, minute]


## Retourne le temps au format 12h (ex: "02:05 PM" ou "08:30 AM")
func get_time_formatted_12h(include_seconds: bool = false) -> String:
	var period: String = "AM" if hour < 12 else "PM"
	var hour_12: int = hour % 12
	if hour_12 == 0:
		hour_12 = 12

	if include_seconds:
		return "%02d:%02d:%02d %s" % [hour_12, minute, second, period]
	return "%02d:%02d %s" % [hour_12, minute, period]
