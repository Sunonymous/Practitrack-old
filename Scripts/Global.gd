##############################
######  PRACTITRACK  #########
##############################
# Dictionary Sets Edition
# Search #! for todos

extends Node

############################################################
############################################################

					  # G L O B A L 

############################################################
############################################################

##############################
  ### Global Singletons ###
##############################

var version = "0.92"
var active_scene_ref # This tracks a reference to the current scene (for errors)
var current_scene
var _set_list: Array = [] # This holds all the individual sets, saved and loaded to file.
var active_set_index: int = 0 # This tracks which set should be active and used.
var interval_value: int = 1 # Should stay at 1 if mode is count and switch to 5 otherwise
var interval_limit: int = 260 #
var modes = ["Interval", "Timer", "Count"] # This holds all possible modes for a set.
var session_mode_options = ["Interval", "Timer", "Count", "Multi"] # This holds possible modes for sessions.
var session_mode # Holds the active mode.
var session_uses_multi_sets = false # Variable to let me know to use the title "Multi"
var session_items_build = [] # Holds a flexible grouping of items to manipulate in a session.
	# Should be in format -- [ [set_id, item_id], [set_id, item_id] ]

##############################
### Processing Functions ###
##############################

# Called when the node enters the scene tree for the first time.
func _ready():
	# Grab the current scene
	var root = get_tree().get_root()
	active_scene_ref = root.get_child(root.get_child_count() - 1)
	# Load Data from File
	# Save to Global singletons
	pass # Replace with function body.


func go_to_scene(path):
	# Deferred to prevent from running while code is still executing
	call_deferred("_deferred_go_to_scene", path)


func _deferred_go_to_scene(path):
	# Now safe to remove scene
	active_scene_ref.free()
	# Load New Scene
	var scene = ResourceLoader.load(path)
	# Instance new scene
	active_scene_ref = scene.instance()
	# Add to active scene as a child of root
	get_tree().get_root().add_child(active_scene_ref)
	# Make it compatible with SceneTree API
	get_tree().set_current_scene(active_scene_ref)


##############################
	### Data Functions ###
##############################

func load_data(path: String = Settings.get_value("program", "data_location")):
	# Loads data from file into variant destination
	var file = File.new()
	# Check if path is valid
	if not file.file_exists(path):
		print("Could not load file at '", path, "'. No such file exists!")
		return
	else:
		# File is present
		file.open(path, file.READ)
		var converted = file.get_var()
		file.close()
		return converted


func save_data(path: String = Settings.get_value("program", "data_location")):
	# Saves data from Global._set_list to file at data_location setting.
	# Check for default path
	if path == "DEFAULT": path = "user://data.set"
	var file = File.new()
	var error = file.open(path, File.WRITE)
	if error == OK:
		file.store_var(_set_list)
		print("Setlist data written successfully to ", path)
	else:
		print("Error writing to file ", path)
	file.close()


func add_set(name_v: String, mode_v: String, items_v: Array = []):
	# Create Set
	assert(mode_v in modes, "The set I am attempting to add does not have any mode I am allowed to use.")
	var set = {
		"name": name_v,
		"mode": mode_v,
		"items": items_v,
		"index": _set_list.size()
	}
	_set_list.append(set)
	

func add_value_to_item(set_index: int, item_index: int, value):
	# For adding values during end of sessions.
	_set_list[set_index]["items"][item_index][1] += value # name index


func remove_set(idx):
	# Removes set at index 'idx'
	_set_list.remove(idx)


func remove_all_sets():
	# Deletes all set data
	_set_list = []


func save_modified_set(new_data: Dictionary):
	# Saves a clone of a set into the official data
	_set_list[active_set_index] = new_data


func get_sets_total():
	# Returns the number of sets saved
	return _set_list.size()


func get_set(idx):
	# Returns set at index idx
	return _set_list[idx]


func get_active_set():
	# Returns the active set
	return _set_list[active_set_index]


func get_set_mode(idx):
	# Returns the mode of the specified set at index idx
	return _set_list[idx]["mode"]


func get_number_of_items_in_set(idx):
	# Returns the number of items in the set at index idx
	return _set_list[idx]["items"].size()


func clone_active_set():
	#! Ensure this works!
	# Dupe the entirety
	var cloned_set = _set_list[active_set_index].duplicate()
	# Dupe the items
	var cloned_items = []
	for val in cloned_set["items"]:
		cloned_items.append(val.duplicate())
	cloned_set["items"] = cloned_items
	return cloned_set


func clone_all_sets():
	return _set_list


func print_set(idx):
	print("Set - '", _set_list[idx]["name"], "'")
	print("Mode: ", _set_list[idx]["mode"])
	print("Items:")
	for item in _set_list[idx]["items"]:
		print("\t", item[0], " - ", item[1])


func print_all_sets():
	for set in range(0, _set_list.size()):
		print_set(set)
		print()


func build_item_address(set_name: String, item_name: String):
	# Provides an address to find an item
	var formed = set_name + "-)))-" + item_name
	print(formed)
	return formed
	

func parse_item_address(address: String):
	return address.split("-)))-")
	

func rebuild_set_indexes():
	# If I allow sets to be sorted later, this function should help rebuild the indexes
	for idx in range(0, get_sets_total()):
		_set_list[idx]["index"] = idx


func process_time(val):
	var hours = 0
	var minutes = 0
	#print("Debug settings 'display_zero_sec' - ", settings["display_zero_sec"])
	# Create temp string
	var temp_str = " "
	# If hours have passed, subtract them.
	if val >= 3600:
		hours = val / 3600
		temp_str += str(hours)
		if Settings.get_value("display", "use_time_letters"): temp_str += "h"
		temp_str += ":"
		val -= 3600 * (val / 3600)
		#! debug print("Time after hours: ", temp_str)
	# If minutes have passed, subtract them.
	if val == 0:
		temp_str += "00"
		if Settings.get_value("display", "use_time_letters"): temp_str += 'm'
		if Settings.get_value("display", "display_zero_seconds"):
			temp_str += ":00"
			if Settings.get_value("display", "use_time_letters"): temp_str += 's'
		return temp_str
	if hours > 0 and val > 0 and val < 60:
		temp_str += "00"
		if Settings.get_value("display", "use_time_letters"): temp_str += 'm'
		temp_str += ':'
	if val >= 60:
		# Leading zero
		minutes = val / 60
		if minutes < 10 and hours >= 1:
			temp_str += "0"
		temp_str += str(minutes)
		if Settings.get_value("display", "use_time_letters"): temp_str += "m"
		val -= minutes * 60
		temp_str += ":"
	# Seconds
	if val == 0 and Settings.get_value("display", "display_zero_seconds"):
		temp_str += "00"
		if Settings.get_value("display", "use_time_letters"): temp_str += 's'
		return temp_str
	# Leading zero
	if val > 0:
		if (val < 10 and minutes > 0) or (val < 10 and hours > 0):
			temp_str += "0"
		temp_str += str(val)
		if Settings.get_value("display", "use_time_letters"): temp_str += "s"
	return temp_str
	

##############################
	### Alert Functions ###
##############################

func alert(message: String, error: bool = false):
	# Create an AcceptPopup
	var pop = AcceptDialog.new()
	# Rename title if error
	if error:
		pop.window_title = "ERROR"
	# Rename its text and make exclusive
	pop.dialog_text = message
	pop.set("popup_exclusive", true)
	# Add it to alerts group
	pop.add_to_group("alerts")
	# Connect it to queue_free
	pop.connect("confirmed", pop, "queue_free")
	# Spawn it on scene root
	active_scene_ref.add_child(pop)
	pop.popup_centered()


func beep():
	queue_free()


func am_i_busy():
	var count = get_tree().get_nodes_in_group("alerts").size()
	if count > 0:
		return true
	return false
