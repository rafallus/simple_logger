@tool
extends EditorPlugin

#

const LOGGER_NAME := "LOG"
const ADDON_PREFIX := "addons/simple_logger/"
const LoggerScript: GDScript = preload("logger.gd")

func _enter_tree() -> void:
	# Add LOG singleton.
	add_autoload_singleton(LOGGER_NAME, "logger.gd")

	# Add project settings.
	if not ProjectSettings.has_setting(ADDON_PREFIX + "output_level"):
		ProjectSettings.set_setting(ADDON_PREFIX + "output_level",
			LoggerScript.Level.VERBOSE)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "output_level",
			type = TYPE_INT,
			hint = PROPERTY_HINT_ENUM,
			hint_string = "Verbose,Debug,Info,Warning,Error,Fatal"
		})
	if not ProjectSettings.has_setting(ADDON_PREFIX + "output_action"):
		ProjectSettings.set_setting(ADDON_PREFIX + "output_action",
			LoggerScript.OUTPUT_FILE | LoggerScript.OUTPUT_PRINT)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "output_action",
			type = TYPE_INT,
			hint = PROPERTY_HINT_FLAGS,
			hint_string = "Print:1,File:2,Console:4"
		})
	if not ProjectSettings.has_setting(ADDON_PREFIX + "print_stack_on_debug"):
		ProjectSettings.set_setting(ADDON_PREFIX + "print_stack_on_debug", false)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "print_stack_on_debug",
			type = TYPE_BOOL
		})
	if not ProjectSettings.has_setting(ADDON_PREFIX + "log_path"):
		var def_path: String = LoggerScript.DEFAULT_LOG_DIR + \
			ProjectSettings.get_setting("application/config/name") + ".log"
		ProjectSettings.set_setting(ADDON_PREFIX + "log_path", def_path)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "log_path",
			type = TYPE_STRING
		})


func _exit_tree() -> void:
	remove_autoload_singleton(LOGGER_NAME)
