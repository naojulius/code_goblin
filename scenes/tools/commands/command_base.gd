extends MarginContainer
class_name CommandBase

signal pressed(command_name: String)
@onready var command_button: Button = $CommandButton

@export var _command_name: String =""

func _ready() -> void:
	command_button.connect("pressed", _command_button_pressed)
	
func _command_button_pressed():
	pressed.emit(_command_name)
