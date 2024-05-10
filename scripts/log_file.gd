@tool
extends RefCounted

const FORCE_FLUSH := -1
const NEVER_FLUSH := 0

var file: FileAccess
var ncalls := 0

func _init(file_access: FileAccess) -> void:
	file = file_access

func write(string: String, flush: int) -> void:
	file.store_line("[%s] %s" % [Time.get_datetime_string_from_system(false, true), string])
	if flush == NEVER_FLUSH:
		return
	ncalls += 1
	if flush == FORCE_FLUSH or ncalls > flush:
		file.flush()
		ncalls = 0
