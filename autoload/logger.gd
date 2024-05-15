@tool
extends Node
##
## Logger that can print messages to different outputs.
##
## [Description of log levels]
## [Description of output options]
##

## Log levels
enum Level {VERBOSE, DEBUG, INFO, WARN, ERROR, FATAL}

## Default directory where logs will be stored. The directory to be used can be
## changed with the setting [code]addons/simple_logger/log_path[/code].
const DEFAULT_LOG_DIR := "user://logs/"
const LOGGER_MODULE := &"Logger"
const DEFAULT_MODULE := &"default"

const OUTPUT_MUTE := 0
const OUTPUT_PRINT := 1
const OUTPUT_FILE := 2
const OUTPUT_CONSOLE := 4
const OUTPUT_ALL := 7

const FORCE_FLUSH := -1
const NEVER_FLUSH := 0

const _LEVELS := ["VERBOSE", "DEBUG", "INFO", "WARN", "ERROR", "FATAL"]

const LogModule: GDScript = preload("../scripts/log_module.gd")

var _debug_print_stack := false
var _num_logs := 1
var _force_flush := 10
var _log_path: String
var _log_files := {}
var _modules := {}
var _console: RichTextLabel
var _allow_verbose := true
var _allow_debug := true
var _allow_info := true
var _allow_warn := true
var _allow_error := true
# TODO:
# * Add colors to modules.

# =============================================================
# ========= Public Functions ==================================

func verbose(message: String, module := &"") -> void:
	__verbose(__get_module(module), message)


func debug(message: String, module := &"") -> void:
	__debug(__get_module(module), message)


func info(message: String, module := &"") -> void:
	__info(__get_module(module), message)


func warning(message: String, error_code := OK, module := &"") -> void:
	var m: String
	if error_code != OK:
		m = "(%d) %s %s" % [error_code, error_string(error_code), message]
	else:
		m = message
	__warning(__get_module(module), m)


func error(message: String, error_code := OK, module := &"") -> void:
	var m: String
	if error_code != OK:
		m = "(%d) %s %s" % [error_code, error_string(error_code), message]
	else:
		m = message
	__error(__get_module(module), m)


func fatal(message: String, error_code := OK, module := &"") -> void:
	var m: String
	if error_code != OK:
		m = "(%d) %s %s" % [error_code, error_string(error_code), message]
	else:
		m = message
	__fatal(__get_module(module), m)


func set_output_level(new_level: Level) -> void:
	module_set_output_level(DEFAULT_MODULE, new_level)


func get_output_level() -> Level:
	return module_get_output_level(DEFAULT_MODULE)


func set_output_flags(flags: int) -> void:
	module_set_output_flags(DEFAULT_MODULE, flags)


func set_print_output(allow: bool) -> void:
	module_set_print_output(DEFAULT_MODULE, allow)


func is_print_output() -> bool:
	return module_is_print_output(DEFAULT_MODULE)


func set_file_output(allow: bool) -> void:
	module_set_file_output(DEFAULT_MODULE, allow)


func is_file_output() -> bool:
	return module_is_file_output(DEFAULT_MODULE)


func set_console_output(allow: bool) -> void:
	module_set_console_output(DEFAULT_MODULE, allow)


func is_console_output() -> bool:
	return module_is_console_output(DEFAULT_MODULE)


func add_module(module_name: StringName, level := Level.VERBOSE, output := 0, log_file := "") -> void:
	if _modules.has(module_name):
		warning("Tried to add a log module that already existed.", OK, LOGGER_MODULE)
	else:
		var mod: LogModule = LogModule.new(level, output, module_name)
		if output & OUTPUT_FILE:
			var path := _log_path if log_file.is_empty() else log_file
			var file := __get_log_file(path)
			mod.set_file(file)
		_modules[module_name] = mod


func clear_modules() -> void:
	var mod: LogModule = _modules[DEFAULT_MODULE]
	_modules.clear()
	_modules[DEFAULT_MODULE] = mod


func module_set_output_level(module_name: StringName, new_level: Level) -> void:
	var mod := __get_module(module_name)
	mod.level = new_level


func module_get_output_level(module_name: StringName) -> Level:
	var mod := __get_module(module_name)
	return mod.level as Level


func module_set_output_flags(module_name: StringName, flags: int) -> void:
	var mod := __get_module(module_name)
	mod.output = flags


func module_set_print_output(module_name: StringName, allow: bool) -> void:
	var mod := __get_module(module_name)
	mod.set_print_output(allow)


func module_is_print_output(module_name: StringName) -> bool:
	var mod := __get_module(module_name)
	return mod.is_print_output()


func module_set_file_output(module_name: StringName, allow: bool) -> void:
	var mod := __get_module(module_name)
	mod.set_file_output(allow)


func module_is_file_output(module_name: StringName) -> bool:
	var mod := __get_module(module_name)
	return mod.is_file_output()


func module_set_console_output(module_name: StringName, allow: bool) -> void:
	var mod := __get_module(module_name)
	mod.set_console_output(allow)


func module_is_console_output(module_name: StringName) -> bool:
	var mod := __get_module(module_name)
	return mod.is_console_output()


func enable_debug_print_stack(enable: bool) -> void:
	_debug_print_stack = enable


func is_enable_debug_print_stack() -> bool:
	return _debug_print_stack


func set_console(console: RichTextLabel) -> void:
	_console = console


# =============================================================
# ========= Callbacks =========================================

func _ready() -> void:
	_debug_print_stack = ProjectSettings.get_setting(
		"addons/simple_logger/print_stack_on_debug", false)
	_num_logs = ProjectSettings.get_setting("addons/simple_logger/log_file/number_of_logs", 5)
	_force_flush = ProjectSettings.get_setting("addons/simple_logger/log_file/force_flush", 10)
	_log_path = ProjectSettings.get_setting("addons/simple_logger/log_file/path", DEFAULT_LOG_DIR)
	if not _log_path.ends_with("/"):
		_log_path += "/"
	_log_path += ProjectSettings.get_setting("addons/simple_logger/log_file/name", "game.log")
	var def_level: Level = ProjectSettings.get_setting(
		"addons/simple_logger/output_level", Level.VERBOSE)
	var def_output: int = ProjectSettings.get_setting(
		"addons/simple_logger/output_action", OUTPUT_PRINT | OUTPUT_FILE)
	add_module(LOGGER_MODULE, Level.VERBOSE, OUTPUT_ALL)
	var def_module: LogModule = LogModule.new(def_level, def_output)
	if def_output & OUTPUT_FILE:
		var log_file := __get_log_file(_log_path)
		def_module.set_file(log_file)
	_modules[DEFAULT_MODULE] = def_module

	_allow_verbose = ProjectSettings.get_setting_with_override("debug/settings/stdout/verbose_stdout")
	_allow_debug = OS.is_debug_build() or ProjectSettings.get_setting(
		"addons/simple_logger/release_options/allow_debug", false)
	_allow_info = OS.is_debug_build() or ProjectSettings.get_setting(
		"addons/simple_logger/release_options/allow_info", true)
	_allow_warn = OS.is_debug_build() or ProjectSettings.get_setting(
		"addons/simple_logger/release_options/allow_warning", true)
	_allow_error = OS.is_debug_build() or ProjectSettings.get_setting(
		"addons/simple_logger/release_options/allow_error", true)


# =============================================================
# ========= Virtual Methods ===================================


# =============================================================
# ========= Private Functions =================================

func __get_module(module_name: StringName) -> LogModule:
	if module_name.is_empty():
		module_name = DEFAULT_MODULE
	var mod: LogModule = _modules.get(module_name)
	if not mod:
		add_module(module_name)
		warning("Created module while trying to access inexisting one", OK, LOGGER_MODULE)
	return mod


func __get_log_file(path: String) -> FileAccess:
	var file: FileAccess = _log_files.get(path)
	if not file:
		var p := path
		var i := path.find("{index}")
		if i != -1:
			# Remove last file
			var pp := path.replace("{index}", str(_num_logs))
			if FileAccess.file_exists(pp):
				var err := DirAccess.remove_absolute(pp)
				if err != OK:
					error("Error while trying to remove log file.", err, LOGGER_MODULE)

			# Rename previous files.
			for j in range(_num_logs - 1, 0):
				pp = path.replace("{index}", str(j))
				if FileAccess.file_exists(pp):
					var new_path := path.replace("{index}", str(j + 1))
					var err := DirAccess.rename_absolute(pp, new_path)
					if err != OK:
						error("Error while trying to rename log file.", err, LOGGER_MODULE)

			p = path.replace("{index}", "1")
		file = FileAccess.open(p, FileAccess.WRITE)
		_log_files[path] = file
	return file


func __verbose(mod: LogModule, message: String) -> void:
	if not _allow_verbose or mod.is_output_allowed(Level.VERBOSE):
		return
	var m: String = mod.prepend_name(message)
	if mod.is_print_output():
		print_verbose(m)
	if mod.is_file_output():
		mod.file.write(m, _force_flush)
	if mod.is_console_output() and _console:
		_console.add_text(m + "\n")


func __debug(mod: LogModule, message: String) -> void:
	if not _allow_debug or mod.is_output_allowed(Level.DEBUG):
		return
	var level := _LEVELS[Level.DEBUG]
	if mod.is_print_output():
		var m := mod.prepend_name("[color=yellow]%s[/color] %s" % [level, message])
		print_rich(m)
		if _debug_print_stack:
			print_stack()
	if mod.is_file_output():
		var m := mod.prepend_name("[%s] %s" % [level, message])
		mod.file.write(m, _force_flush)
	if mod.is_console_output() and _console:
		__add_console_message(message, mod.name, level, Color.ORANGE)


func __info(mod: LogModule, message: String) -> void:
	if not _allow_info or mod.is_output_allowed(Level.INFO):
		return
	var level := _LEVELS[Level.INFO]
	if mod.is_print_output():
		var m := mod.prepend_name("[color=yellow]%s[/color] %s" % [level, message])
		print_rich(m)
	if mod.is_file_output():
		var m := mod.prepend_name("[%s] %s" % [level, message])
		mod.file.write(m, _force_flush)
	if mod.is_console_output() and _console:
		__add_console_message(message, mod.name, level, Color.BLUE)


func __warning(mod: LogModule, message: String) -> void:
	if not _allow_warn or mod.is_output_allowed(Level.WARN):
		return
	var level := _LEVELS[Level.WARN]
	if mod.is_print_output():
		push_warning(message)
	if mod.is_file_output():
		var m := mod.prepend_name("[%s] %s" % [level, message])
		mod.file.write(m, _force_flush)
	if mod.is_console_output() and _console:
		__add_console_message(message, mod.name, level, Color.YELLOW)


func __error(mod: LogModule, message: String) -> void:
	if not _allow_error or mod.is_output_allowed(Level.ERROR):
		return
	var level := _LEVELS[Level.ERROR]
	if mod.is_print_output():
		push_error(message)
		print_stack()
		print_tree()
	if mod.is_file_output():
		var m := mod.prepend_name("[%s] %s" % [level, message])
		mod.file.write(m, FORCE_FLUSH)
	if mod.is_console_output() and _console:
		__add_console_message(message, mod.name, level, Color.RED)


func __fatal(mod: LogModule, message: String) -> void:
	if mod.is_output_allowed(Level.FATAL):
		return
	var level := _LEVELS[Level.FATAL]
	if mod.is_print_output():
		push_error(message)
		print_stack()
		print_tree()
	if mod.is_file_output():
		var m := mod.prepend_name("[%s] %s" % [level, message])
		mod.file.write(m, FORCE_FLUSH)
	if mod.is_console_output() and _console:
		__add_console_message(message, mod.name, level, Color.RED)


func __add_console_message(message: String, module_name: String, level: String, level_color: Color) -> void:
	if not module_name.is_empty():
		_console.add_text(module_name + ": ")
	_console.push_color(level_color)
	_console.add_text(level)
	_console.pop()
	_console.add_text(message + "\n")

#func __create_module(output_level: Level, output_flags: int, mod_name := "")  -> LogModule:
	#var mod: LogModule = LogModule.new()
	#mod.level = output_level
	#mod.output = output_flags
	#mod.name = mod_name
	#return mod


# =============================================================
# ========= Signal Callbacks ==================================

