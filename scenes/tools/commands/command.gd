extends Resource
class_name Command
const CODE_COMMAND = preload("uid://dt5xmylg5nude")

var unit = null
@export var avatar: PackedScene
@export var commands: Array[PackedScene] = [
	CODE_COMMAND
]
