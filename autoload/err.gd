@tool
extends Node

##
## Error and warning helper.
##
## .
##

### Completely ignore the error.
#const ERROR_IGNORE := 0
### A message is printed an program should continue.
#const ERROR_NOTIFY_AND_CONTINUE := 1
### A message is printed an program should break to handle it.
#const ERROR_NOTIFY_AND_BREAK := 2
### A message is printed and program is aborted.
#const ERROR_NOTIFY_AND_EXIT := 3
#
### Default behaviour when checking for errors.
#const ERROR_DEFAULT_ACTION := ERROR_NOTIFY_AND_BREAK
#
### The action to be executed when errors are found, if not specified by the
### action input of the different error checking functions.
#var error_action := ERROR_DEFAULT_ACTION

# =============================================================
# ========= Public Functions ==================================

func checkerr(err: int, fatal := false, message := "") -> bool:
	if err != OK:
		if fatal:
			Log.fatal(message, err)
		else:
			Log.fatal(message, err)
		return false
	return true


func check(arg: bool, message: String, fatal := false) -> bool:
	if not arg:
		if fatal:
			Log.fatal(message)
		else:
			Log.error(message)
		return false
	return true


### Receives an error value and takes an action like printing a message or
### quiting the program. If [param action] is equal to -1, the action is
### determined by [member error_action]. Returns [code]true[/code] if there was
### an error that needs to be managed, depending on the value of [param action].
#func PRINTERR(err: int, action: int = -1) -> bool:
	#var act := error_action if action == -1 else action
	#if err != OK:
		## The generic FAILED error doesn't print a message.
		#if act >= ERROR_NOTIFY_AND_CONTINUE and not err == FAILED:
			##Log.error("", &"", err)
			#pass
		#if act == ERROR_NOTIFY_AND_EXIT:
			#if Engine.is_editor_hint():
				#assert(err == OK, error_string(err))
			#else:
				#OS.alert(error_string(err), "Error!")
				#self.get_tree().quit(err)
		#if act <= ERROR_NOTIFY_AND_CONTINUE:
			#return false
		#else:
			#return true
	#return false
#
#
### Same as [method PRINTERR] but is quietly executed without returning any
### parameter.
#func PRINTERRQ(err: int, action: int = -1) -> void:
	#@warning_ignore("return_value_discarded")
	#PRINTERR(err, action)
#
#
### Same as [method PRINTERR] but intended to be used when resizing arrays:
### [codeblock]
### var new_size := 100
### var my_array := []
### Err.CHK_RSZ(my_array.resize(new_size))
### [/codeblock]
#func CHK_RSZ(err: int, action: int = -1) -> void:
	#PRINTERRQ(err, action)
#
#
### Use this function to check if adding elements to a PackedArray fails. It will
### consider the cause of failure to be [enum @GlobalScope.ERR_OUT_OF_MEMORY].
### [codeblock]
### var my_array := PackedInt32Array()
### Err.CHK_APPEND(my_array.push_back(10))
### [/codeblock]
#func CHK_APPEND(failed: bool, action: int = -1) -> void:
	#if failed:
		#PRINTERRQ(ERR_OUT_OF_MEMORY, action)
#
#
### Helper function to connect a signal.
#func CONN(signal_: Signal, callable: Callable, flags: int = 0) -> void:
	#var err := signal_.connect(callable, flags)
	#if err != OK and ERROR_DEFAULT_ACTION >= ERROR_NOTIFY_AND_CONTINUE:
		#printerr("Cannot connect signal %s to method %s." % [signal_.get_name(), callable.get_method()])
#
#
### Shows a warning if a dictionary element is not found while trying to erase
### it.
### [codeblock]
### var my_dict := {}
### my_data[32] = 1
### Err.WARN_DICTERASE(my_dict.erase(0), "numbered")
### [/codeblock]
### It will print the message [i]Trying to erase numbered element from
### Dictionary, but it wasn't found[/i].
#func WARN_DICTERASE(erased: bool, element: String) -> void:
	#if not erased and ERROR_DEFAULT_ACTION >= ERROR_NOTIFY_AND_CONTINUE:
		#push_warning("Trying to erase %s element from Dictionary, but it wasn't found." % element)
#
#
### Helper function to open a file.
#func OPEN_FILE(path: String, flags: int, check_exists: bool = false) -> FileAccess:
	#if check_exists and not FileAccess.file_exists(path):
		#PRINTERRQ(ERR_FILE_NOT_FOUND)
		#return null
	#var file := FileAccess.open(path, flags)
	#PRINTERRQ(FileAccess.get_open_error())
	#return file


# =============================================================
# ========= Callbacks =========================================


# =============================================================
# ========= Virtual Methods ===================================


# =============================================================
# ========= Private Functions =================================


# =============================================================
# ========= Signal Callbacks ==================================
