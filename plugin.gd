@tool
extends EditorPlugin

#

const LOGGER_NAME := "Log"
const ERR_NAME := "Err"
const BENCHMARK_NAME := "Benchmark"
const ADDON_PREFIX := "addons/simple_logger/"
const LoggerScript: GDScript = preload("autoload/logger.gd")

func _enter_tree() -> void:
	# Add LOG singleton.
	add_autoload_singleton(LOGGER_NAME, "autoload/logger.gd")

	# Add ERR singleton.
	add_autoload_singleton(ERR_NAME, "autoload/err.gd")

	# Add BMK singleton.
	add_autoload_singleton(BENCHMARK_NAME, "autoload/benchmark.gd")

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
		ProjectSettings.set_initial_value(ADDON_PREFIX + "output_level", LoggerScript.Level.VERBOSE)
	if not ProjectSettings.has_setting(ADDON_PREFIX + "output_action"):
		ProjectSettings.set_setting(ADDON_PREFIX + "output_action",
			LoggerScript.OUTPUT_FILE | LoggerScript.OUTPUT_PRINT)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "output_action",
			type = TYPE_INT,
			hint = PROPERTY_HINT_FLAGS,
			hint_string = "Print:1,File:2,Console:4"
		})
		ProjectSettings.set_initial_value(ADDON_PREFIX + "output_action",
			LoggerScript.OUTPUT_FILE | LoggerScript.OUTPUT_PRINT)
	if not ProjectSettings.has_setting(ADDON_PREFIX + "print_stack_on_debug"):
		ProjectSettings.set_setting(ADDON_PREFIX + "print_stack_on_debug", false)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "print_stack_on_debug",
			type = TYPE_BOOL
		})
		ProjectSettings.set_initial_value(ADDON_PREFIX + "print_stack_on_debug",
			false)
	if not ProjectSettings.has_setting(ADDON_PREFIX + "log_file/path"):
		ProjectSettings.set_setting(ADDON_PREFIX + "log_file/path", LoggerScript.DEFAULT_LOG_DIR)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "log_file/path",
			type = TYPE_STRING,
			hint = PROPERTY_HINT_DIR
		})
		ProjectSettings.set_initial_value(ADDON_PREFIX + "log_file/path",
			LoggerScript.DEFAULT_LOG_DIR)
	if not ProjectSettings.has_setting(ADDON_PREFIX + "log_file/name"):
		ProjectSettings.set_setting(ADDON_PREFIX + "log_file/name",
			ProjectSettings.get_setting("application/config/name") + "_{index}.log")
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "log_file/name",
			type = TYPE_STRING
		})
		ProjectSettings.set_initial_value(ADDON_PREFIX + "log_file/name",
			"game.log")
	if not ProjectSettings.has_setting(ADDON_PREFIX + "log_file/number_of_logs"):
		ProjectSettings.set_setting(ADDON_PREFIX + "log_file/number_of_logs", 5)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "log_file/number_of_logs",
			type = TYPE_INT,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "1,32"
		})
		ProjectSettings.set_initial_value(ADDON_PREFIX + "log_file/number_of_logs", 5)
	if not ProjectSettings.has_setting(ADDON_PREFIX + "log_file/force_flush"):
		ProjectSettings.set_setting(ADDON_PREFIX + "log_file/force_flush", 10)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "log_file/force_flush",
			type = TYPE_INT,
			hint = PROPERTY_HINT_RANGE,
			hint_string = "0,64,1,or_greater"
		})
		ProjectSettings.set_initial_value(ADDON_PREFIX + "log_file/force_flush", 10)
	if not ProjectSettings.has_setting(ADDON_PREFIX + "release_options/allow_verbose"):
		ProjectSettings.set_setting(ADDON_PREFIX + "release_options/allow_verbose", false)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "release_options/allow_verbose",
			type = TYPE_BOOL
		})
	ProjectSettings.set_initial_value(ADDON_PREFIX + "release_options/allow_verbose", false)
	if not ProjectSettings.has_setting(ADDON_PREFIX + "release_options/allow_debug"):
		ProjectSettings.set_setting(ADDON_PREFIX + "release_options/allow_debug", false)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "release_options/allow_debug",
			type = TYPE_BOOL
		})
		ProjectSettings.set_initial_value(ADDON_PREFIX + "release_options/allow_debug", false)
	if not ProjectSettings.has_setting(ADDON_PREFIX + "release_options/allow_info"):
		ProjectSettings.set_setting(ADDON_PREFIX + "release_options/allow_info", true)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "release_options/allow_info",
			type = TYPE_BOOL
		})
		ProjectSettings.set_initial_value(ADDON_PREFIX + "release_options/allow_info", true)
	if not ProjectSettings.has_setting(ADDON_PREFIX + "release_options/allow_warning"):
		ProjectSettings.set_setting(ADDON_PREFIX + "release_options/allow_warning", true)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "release_options/allow_warning",
			type = TYPE_BOOL
		})
		ProjectSettings.set_initial_value(ADDON_PREFIX + "release_options/allow_warning", true)
	if not ProjectSettings.has_setting(ADDON_PREFIX + "release_options/allow_error"):
		ProjectSettings.set_setting(ADDON_PREFIX + "release_options/allow_error", true)
		ProjectSettings.add_property_info({
			name = ADDON_PREFIX + "release_options/allow_error",
			type = TYPE_BOOL
		})
		ProjectSettings.set_initial_value(ADDON_PREFIX + "release_options/allow_error", true)


func _exit_tree() -> void:
	remove_autoload_singleton(BENCHMARK_NAME)
	remove_autoload_singleton(ERR_NAME)
	remove_autoload_singleton(LOGGER_NAME)


func _disable_plugin() -> void:
	# Remove project settings.
	ProjectSettings.clear(ADDON_PREFIX + "output_level")
	ProjectSettings.clear(ADDON_PREFIX + "output_action")
	ProjectSettings.clear(ADDON_PREFIX + "print_stack_on_debug")
	ProjectSettings.clear(ADDON_PREFIX + "log_file/path")
	ProjectSettings.clear(ADDON_PREFIX + "log_file/name")
	ProjectSettings.clear(ADDON_PREFIX + "log_file/number_of_logs")
	ProjectSettings.clear(ADDON_PREFIX + "log_file/force_flush")
	ProjectSettings.clear(ADDON_PREFIX + "release_options/allow_verbose")
	ProjectSettings.clear(ADDON_PREFIX + "release_options/allow_debug")
	ProjectSettings.clear(ADDON_PREFIX + "release_options/allow_info")
	ProjectSettings.clear(ADDON_PREFIX + "release_options/allow_warning")
	ProjectSettings.clear(ADDON_PREFIX + "release_options/allow_error")
