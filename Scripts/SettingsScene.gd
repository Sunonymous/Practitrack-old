extends Node2D


# Declare member variables here. Examples:
var set_data_path = ""
const DEFAULT_DATAPATH = "user://data.set"
var setting_label_font = DynamicFont.new()


onready var nd_data_loc_fullbox = $ScreenMarg/Panel/ContentMarg/ContentVBox/SettingsScrollCont/SettingsContainer/DataLocHBox
onready var nd_settings_cont = $ScreenMarg/Panel/ContentMarg/ContentVBox/SettingsScrollCont/SettingsContainer
onready var nd_delete_button = $ScreenMarg/Panel/ContentMarg/ContentVBox/SettingsScrollCont/SettingsContainer/DeleteDataButton
onready var nd_open_folder_btn = $ScreenMarg/Panel/ContentMarg/ContentVBox/SettingsScrollCont/SettingsContainer/OpenFolderButton
onready var nd_folder_diag = $ScreenMarg/DataLocFileDialog

var settings_titles = {}
var settings_descriptions = {}

# Local copy of settings
var settings = Settings.get_all_settings()
var settings_nd_ref = {}

# Dictionary Container to indicate which group contains which setting
var all_settings_groups = {}


# Called when the node enters the scene tree for the first time.
func _ready():
	# Load font
	setting_label_font.font_data = load("res://Font/Roboto-Medium.ttf")
	setting_label_font.size = 22
	# Set to current scene
	Global.active_scene_ref = self
	# Make a local copy of the settings values (Done in member variables)
	# If data.set location is DEFAULT, set open file location to user directory.
	if Settings.get_value("program", "data_location") == "DEFAULT" or Settings.get_value("program", "data_location").substr(0,61) == OS.get_user_data_dir():
		nd_folder_diag.current_dir = OS.get_user_data_dir()
	# Update labels, and tooltip text
	add_settings_descriptions()
	# Set tooltip for data location
	var fmdatastring = "Update the location of your saved 'data.set' file.\nCurrently saved in %s"
	var full_datapath = Settings.get_value("program", "data_location")
	# Break up path
	if full_datapath.length() >= 50:
		var expanded_path = full_datapath.substr(0, 49)
		expanded_path += "\n"
		expanded_path += full_datapath.substr(49, full_datapath.length())
		full_datapath = expanded_path
	$ScreenMarg/Panel/ContentMarg/ContentVBox/SettingsScrollCont/SettingsContainer/DataLocHBox/DataLocLabel.set("hint_tooltip", fmdatastring % full_datapath)
	# For every key in config dictionary, add a checkbox
	for group in settings.keys():
		# Create new group
		var settings_group = []
		for key in settings[group].keys():
			# Add to name arrays
			settings_group.append(key)
			if key == "data_location": continue # Data location configured elsewise
			# Match key based on type
			match (Settings._setting_type[key]):
				"bool":
					var ckbx = CheckButton.new()
					ckbx.text = settings_titles[key]
					ckbx.set("hint_tooltip", settings_descriptions[key])
					# Set editor_description note
					ckbx.set("editor_description", key)
					# Set value to whether true or not
					if settings[group][key]: ckbx.pressed = true
					# Add to parent and group
					nd_settings_cont.add_child(ckbx)
					ckbx.add_to_group("scroll_ops")
					# Add reference to node dictionary
					settings_nd_ref[key] = ckbx
				"int":
					#! Add subtle left and right margin
					var marg = MarginContainer.new()
					var lnedcont = HBoxContainer.new()
					var txt = RichTextLabel.new()
					var lned = LineEdit.new()
					marg.set("custom_constants/margin_left", 5)
					marg.set("custom_constants/margin_right", 8)
					marg.set("custom_constants/margin_top", 3)
					marg.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					marg.size_flags_vertical = Control.SIZE_EXPAND_FILL
					lnedcont.add_child(txt)
					lnedcont.add_child(lned)
					marg.add_child(lnedcont)
					txt.add_font_override("font", setting_label_font)
					txt.text = settings_titles[key]
					txt.size_flags_horizontal = Control.SIZE_EXPAND_FILL
					txt.size_flags_vertical = Control.SIZE_EXPAND_FILL
					txt.set("hint_tooltip", settings_descriptions[key])
					# Set editor_description note
					txt.set("editor_description", key)
					# Set default value
					lned.text = str(Settings.get_value(group, key))
					# Add to parent and group
					nd_settings_cont.add_child(marg)
					lnedcont.add_to_group("scroll_ops")
					# Add reference to node dictionary
					settings_nd_ref[key] = lned
		# Add compiled settings names to master list
		all_settings_groups[group] = settings_group
	# Add all nodes in scroll to group
	nd_open_folder_btn.add_to_group("scroll_ops")
	nd_delete_button.add_to_group("scroll_ops")
	nd_data_loc_fullbox.add_to_group("scroll_ops")
	var scroll_ops = get_tree().get_nodes_in_group("scroll_ops")
	# Move Delete button to the bottom
	nd_delete_button.get_parent().move_child(nd_delete_button, scroll_ops.size())
	# Set initial data location to temp copy
	settings["program"]["data_location"] = Settings.get_value("program", "data_location")
	


func add_settings_descriptions():
	# Add the setting's titles
	settings_titles["data_location"] = "I should not appear."
	settings_titles["pause_on_minimize"] = "Pause When Minimized"
	settings_titles['use_time_letters'] = "Use Time Letters"
	settings_titles["save_with_active_timers"] = "Save While Timers Active"
	settings_titles["display_zero_seconds"] = "Display Empty Seconds"
	settings_titles["instant_timer_deletion"] = "Reset Timers Instantly"
	settings_titles["max_interval_limit"] = "Max Interval Limit"
	# Add the setting's descriptions
	settings_descriptions["data_location"] = "Wonder where I'll appear."
	settings_descriptions["pause_on_minimize"] = "Pause the app when it is minimized. Currently non-functional."
	settings_descriptions["use_time_letters"] = "Display the letters 'h', 'm', and 's' in timer values."
	settings_descriptions["save_with_active_timers"] = "Allow finishing a session with active timers."
	settings_descriptions["display_zero_seconds"] = "Display 1m:00s instead of 1m in timer mode."
	settings_descriptions["instant_timer_deletion"] = "Reset a timer instantly when the button is pressed."
	settings_descriptions["max_interval_limit"] = "The maximum value to add/subtract intervals in a session."


func _on_CancelButton_pressed():
	#! Add confirmation
	Global.go_to_scene("res://Scenes/MainMenu.tscn")


func _on_DataLocButton_pressed():
	# Show folder selection
	nd_folder_diag.popup_centered()


func _on_OpenFolderButton_pressed():
	# Open folder containing data.set
	if Settings.get_value("program", "data_location") == "DEFAULT":
		var path = ProjectSettings.globalize_path("user://")
		var _error = OS.shell_open(path)
	else:
		var filepath = Settings.get_value("program", "data_location")
		var _error = OS.shell_open(filepath.substr(0, filepath.length() - 8))


func _on_SaveButton_pressed():
	#! Confirm action
	# Check if any invalid characters in integer line edit
	for group in settings:
		for key in settings[group].keys():
			if Settings._setting_type[key] == "int":
				if not settings_nd_ref[key].text.is_valid_integer():
					print("BAM")
					Global.alert("Setting %s contains an invalid character." % settings_titles[key], true) # true for error
					return
	# Update data location
	Settings.set_value("program", "data_location", settings["program"]["data_location"])
	# Loop through the settings
	for group in settings:
		for key in settings[group].keys():
			# Skip data location
			if key == "data_location": continue
			# Match based on variant type
			match Settings._setting_type[key]:
				"bool":
					settings[group][key] = settings_nd_ref[key].pressed
					Settings.set_value(group, key, settings[group][key])
				"int":
					settings[group][key] = int(settings_nd_ref[key].text)
					Settings.set_value(group, key, settings[group][key])
	#! Update save function once rewritten
	Settings.save_settings()
	# Return to menu
	Global.go_to_scene("res://Scenes/MainMenu.tscn")

func _on_DataLocFileDialog_file_selected(path):
	# Update local copy
	if "data.set" in path:
		# Check if it is the same as DEFAULT
		var default_path = ProjectSettings.globalize_path("user://")
		# Get the total length of path
		var until_dataset = path.length() - 8
		if path.substr(0, until_dataset) == default_path:
			settings["program"]["data_location"] = "DEFAULT"
		else:
			settings["program"]["data_location"] = path
	# Error popup for incorrect path
	else:
		Global.alert("Incorrect file selected.", true) # true because error



func if_file_exists_delete(path: String):
	# Check for path
	var doom = File.new()
	var doomer = Directory.new()
	if doom.file_exists(path):
		var result = doomer.remove(path)
		if result == OK:
			var msg = "Successfully removed file at '%s'."
			Global.alert(msg % path)
			print("Successfully removed file at ", path)
		else:
			var msg = "Could not remove file at '%s'."
			Global.alert(msg % path, true) # true for error
			print("Error removing file at ", path)
	else:
		var msg = "Data at path '%s' does not exist."
		Global.alert(msg % path, true) # true for error
		print("Data at path '", path, "' does not exist.")


func _on_DeleteDataButton_pressed():
	#! Confirm
	print("User has chosen to erase data.")
	# Delete the path and default files
	if Settings.get_value("program", "data_location") != "DEFAULT":
		if_file_exists_delete(Settings.get_value("program", "data_location"))
		if_file_exists_delete(settings["program"]["data_loc"])
	if_file_exists_delete("user://config.cfg")
	if_file_exists_delete("user://data.set")
	# Remove pre-loaded data
	Global.remove_all_sets()
	Global.active_set_index = 0
	# Return to menu
	Global.go_to_scene("res://Scenes/MainMenu.tscn")
