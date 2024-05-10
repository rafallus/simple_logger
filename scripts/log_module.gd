@tool
extends RefCounted

const OUTPUT_MUTE := 0
const OUTPUT_PRINT := 1
const OUTPUT_FILE := 2
const OUTPUT_CONSOLE := 4

const LogFile: GDScript = preload("log_file.gd")

var level: int = 0
var output := OUTPUT_MUTE:
	set(value):
		output = value & (OUTPUT_PRINT | OUTPUT_FILE | OUTPUT_CONSOLE)
var file: LogFile
var name: String

func _init(output_level: int, output_flags: int, mod_name := ""):
	level = output_level
	output = output_flags
	name = mod_name

func is_muted() -> bool:
	return output == OUTPUT_MUTE

func mute() -> void:
	output = OUTPUT_MUTE

func is_print_output() -> bool:
	return output & OUTPUT_PRINT

func set_print_output(allow: bool) -> void:
	if allow:
		output |= OUTPUT_PRINT
	else:
		output &= OUTPUT_PRINT

func is_file_output() -> bool:
	return output & OUTPUT_FILE && file

func set_file_output(allow: bool) -> void:
	if allow:
		output |= OUTPUT_FILE
	else:
		output &= OUTPUT_FILE

func is_console_output() -> bool:
	return output & OUTPUT_CONSOLE

func set_console_output(allow: bool) -> void:
	if allow:
		output |= OUTPUT_CONSOLE
	else:
		output &= OUTPUT_CONSOLE

func is_output_allowed(out_level: int) -> bool:
	return level <= out_level

func prepend_name(string: String) -> String:
	if name.is_empty():
		return string
	else:
		return "%s: %s" % [name, string]


func set_file(in_file: FileAccess) -> void:
	file = LogFile.new(in_file)
