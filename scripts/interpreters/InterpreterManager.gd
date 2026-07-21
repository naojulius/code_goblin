extends Node
const C_SHARP = preload("uid://bvofuoul0cu67")
const PYTHON = preload("uid://tri3vsgf3hax")

var current_language: String = "python"
var file_extension: String = ".py"

func get_highlighter() -> Resource:
	match current_language:
		"c#":
			return C_SHARP
		"python":
			return PYTHON
		_:
			return C_SHARP

func get_interpreter(unit_name: String):
	match current_language:
		"c#":
			file_extension = ".cs"
			return handle_csharp(unit_name)
		"python":
			file_extension = ".py"
			return handle_python(unit_name)

func handle_csharp(unit_name: String):
	match unit_name.to_lower():
		"paysant":
			return Paysant_CSharp_Interpreter.new()
			
func handle_python(unit_name: String):
	match unit_name.to_lower():
		"paysant":
			return Paysant_Python_Interpreter.new()
