##
## Brief description.
##
## Long description.
##
@tool
extends Node

enum Level {VERBOSE, DEBUG, INFO, WARN, ERROR, FATAL}

const OUTPUT_MUTE := 0
const OUTPUT_PRINT := 1
const OUTPUT_FILE := 2
const OUTPUT_CONSOLE := 4

const _LEVELS := ["VERBOSE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL"]

var _modules := {}
var _def_module: Module
var _debug_print_stack := false


###############################################################
####======= Public Functions ==============================####

func put(level: Level, message: String, module := &"", error_code := -1) -> void:
	var mod := __get_module(module)
	if mod.output == OUTPUT_MUTE or mod.level > level:
		return
	var module_string := "" if mod == _def_module else String(module) + ": "
	var err_string := error_string(error_code) + " " \
			if error_code > 0 and error_code <= ERR_PRINTER_ON_FIRE else ""
	var base_string := module_string + err_string + message
	var string := base_string if level == Level.VERBOSE \
		else "[%s] %s" % [_LEVELS[level], base_string]
	if mod.is_print_output():
		match level:
			Level.VERBOSE, Level.INFO:
				print(string)
			Level.DEBUG:
				print(string)
				if _debug_print_stack:
					print_stack()
			Level.WARN:
				print(string)
				push_warning(base_string)
			Level.ERROR, Level.FATAL:
				printerr(string)
				push_error(base_string)
				print_stack()
				print_tree()
	if mod.is_file_output():
		pass
	#[Time][DEBUG] Module: Error Message. Custom Message

	#var output = format(output_format, level, module, message, error_code)
#
	#if output_strategy & STRATEGY_PRINT:
		#print(output)
#
	#if output_strategy & STRATEGY_EXTERNAL_SINK:
		#module_ref.get_external_sink().write(output, level)
#
	#if output_strategy & STRATEGY_MEMORY:
		#memory_buffer[memory_idx] = output
		#memory_idx += 1
		#invalid_memory_cache = true
		#if memory_idx >= max_memory_size:
			#memory_idx = 0
			#memory_first_loop = false

func clear_modules() -> void:
	_modules.clear()


func set_output_level(new_level: Level) -> void:
	_def_module.level = new_level


func get_output_level() -> Level:
	return _def_module.level


func set_output_action_flags(flags: int) -> void:
	_def_module.output = flags


func set_output_action_print(allow: bool) -> void:
	if allow:
		_def_module.output |= OUTPUT_PRINT
	else:
		_def_module.output &= ~OUTPUT_PRINT


func set_output_action_file(allow: bool) -> void:
	if allow:
		_def_module.output |= OUTPUT_FILE
	else:
		_def_module.output &= ~OUTPUT_FILE


func set_output_action_console(allow: bool) -> void:
	if allow:
		_def_module.output |= OUTPUT_CONSOLE
	else:
		_def_module.output &= ~OUTPUT_CONSOLE


func add_module(module_name: StringName, level := Level.VERBOSE, output := 0) -> void:
	if _modules.has(module_name):
		pass
	else:
		_modules[module_name] = Module.new(level, output)


func enable_debug_print_stack(enable: bool) -> void:
	_debug_print_stack = enable


###############################################################
####======= Callbacks =====================================####

func _ready() -> void:
	var def_level: Level = ProjectSettings.get_setting(
		"addons/simple_logger/output_level", Level.VERBOSE)
	var def_output: int = ProjectSettings.get_setting(
		"addons/simple_logger/output_action", OUTPUT_PRINT)
	_def_module = Module.new(def_level, def_output)
	_debug_print_stack = ProjectSettings.get_setting(
		"addons/simple_logger/print_stack_on_debug", false)


###############################################################
####======= Virtual Methods ===============================####


###############################################################
####======= Private Functions =============================####

func __get_module(module_name: StringName) -> Module:
	if module_name.is_empty():
		return _def_module
	else:
		var mod: Module = _modules.get(module_name)
		if not mod:
			pass
		return mod


###############################################################
####======= Signal Callbacks ==============================####


###############################################################
####======= Internal Classes ==============================####

class Module:
	var level: Level = Level.VERBOSE
	var output := OUTPUT_MUTE:
		set(value):
			output = value & (OUTPUT_PRINT | OUTPUT_FILE | OUTPUT_CONSOLE)

	func _init(output_level: Level, output_flags: int):
		level = output_level
		output = output_flags

	func is_muted() -> bool:
		return output == OUTPUT_MUTE

	func mute() -> void:
		output = OUTPUT_MUTE

	func is_print_output() -> bool:
		return output & OUTPUT_PRINT

	func is_file_output() -> bool:
		return output & OUTPUT_FILE

	func is_console_output() -> bool:
		return output & OUTPUT_CONSOLE

	func is_output_allowed(out_level: Level) -> bool:
		return level <= out_level

