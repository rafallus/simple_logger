@tool
extends EditorPlugin

#

const LOGGER_NAME := "LOG"
const ADDON_PREFIX := "addons/simple_logger"

func _enter_tree() -> void:
	pass
	## Add ERR singleton.
	#add_autoload_singleton(ERR_NAME, ADDON_PATH + "autoload/err.gd")
#
	## Get DATA singleton script from path in project settings.
	#if not ProjectSettings.has_setting(ADDON_PREFIX + "data_script_path"):
		#ProjectSettings.set_setting(ADDON_PREFIX + "data_script_path",
			#ADDON_PATH + DEFAULT_DATA_PATH)
		#ProjectSettings.add_property_info({
			#name = "addons/true_data/data_script_path",
			#type = TYPE_STRING,
			#hint = PROPERTY_HINT_FILE,
			#hint_string = "*.gd"
		#})
	#data_path = ProjectSettings.get_setting(ADDON_PREFIX + "data_script_path")
	#add_autoload_singleton(DATA_NAME, data_path)
#
	## Add IO singleton.
	##add_autoload_singleton(IO_NAME, ADDON_PATH + "autoload/file_io.gd")
#
	## Load resources.
	#DataCreator = load("res://addons/true_data/data_creator/data_creator.gd")
	#DataType = load("res://addons/true_data/data_creator/data_type.gd")
	#plugin = load("res://addons/true_data/data_creator/plugin.tscn").instantiate()
	#plugin.set_undoredo(get_undo_redo())
	#button = add_control_to_bottom_panel(plugin, "Data Creator")
	#button.hide()
#
	## If project settings change, make sure to have the correct path to DATA
	## singleton.
	#if ProjectSettings.settings_changed.connect(_on_project_settings_changed) != OK:
		#printerr("Cannot connect 'settings_changed' signal.")


func _exit_tree() -> void:
	pass
	#remove_control_from_bottom_panel(plugin)
	#plugin.free()
	#button = null
#
	###remove_autoload_singleton(IO_NAME)
	#remove_autoload_singleton(DATA_NAME)
	#remove_autoload_singleton(ERR_NAME)
#
	#ProjectSettings.settings_changed.disconnect(_on_project_settings_changed)
