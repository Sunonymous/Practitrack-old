extends Node2D

##############################
  ### Member Variables ###
##############################

var max_set_index = 0 # Used to track how buttons of set_options function
onready var file = File.new() # Used to save and load data

### Button Variables
onready var btn_start_session = $ScreenMargCont/MenuGroupsContainer/SessionMargContainer/NewSessionButton
onready var btn_create_set = $ScreenMargCont/MenuGroupsContainer/MenuButtons/CreateSetButton
onready var btn_modify_set = $ScreenMargCont/MenuGroupsContainer/MenuButtons/ModifySetButton
onready var btn_view_times = $ScreenMargCont/MenuGroupsContainer/MenuButtons/ViewTimesButton
onready var set_options = $ScreenMargCont/MenuGroupsContainer/ActiveSetCont/SetsOptionButton
onready var btn_prev_set = $ScreenMargCont/MenuGroupsContainer/ActiveSetCont/PrevSetButton
onready var btn_next_set = $ScreenMargCont/MenuGroupsContainer/ActiveSetCont/NextSetButton

##############################
 ### Processing Functions ###
##############################

func _ready():
	# Set reference to current scene
	Global.active_scene_ref = self
	# Update version text
	update_version_label()
	# Center position on screen
	var screen_size = OS.get_screen_size(0)
	var window_size = OS.get_window_size()
	OS.set_window_position(screen_size*0.5 - window_size*0.5)
	
	# Settings Loading
	if file.file_exists("user://config.cfg"):
		Settings.load_settings()
	else:
		print("No 'config.cfg' file present. Creating new file.")
		Settings.save_settings()
	file.close()
	
	# Reset Interval Limit
	Global.interval_limit = Settings.get_value("integer", "max_interval_limit")
	
	# Data Loading
	var data_path = Settings.get_value("program", "data_location")
	# Check for default path
	if data_path == "DEFAULT": data_path = "user://data.set"
	if file.file_exists(data_path):
		Global._set_list = Global.load_data(data_path)
	else:
		# No data.set file found. Prompt for set creation.
		Global.alert("No set data found! Create a set to save data.")
		btn_start_session.disabled = true
		btn_modify_set.disabled = true
		btn_view_times.disabled = true
		btn_next_set.disabled = true
		btn_prev_set.disabled = true
		set_options.disabled = true
	#Global.print_all_sets() #!Debug
	# Debug set index testing
#	if Global._set_list.size() > 0:
#		for idx in range(0, Global.get_sets_total()):
#			if Global._set_list[idx]["index"] == idx:
#				print(true)
#			else:
#				print(false)
	
	# Update Active Set Index
	Global.active_set_index = 0
	# Set Max set index for buttons
	var total_sets = Global.get_sets_total()
	if total_sets >= 1:
		max_set_index = Global.get_sets_total() - 1
		
	# Populate Sets List
	populate_option_list()

##############################
  ### Data Handling ###
##############################

func populate_option_list():
	# First clear list.
	set_options.clear()
	if Global.get_sets_total() != 0:
		# if there are any items, then we add them
		print("Populating set options list.")
		for num in range(0, Global.get_sets_total()):
			set_options.add_item(Global.get_set(num)["name"])


func _on_SetsOptionButton_item_selected(_index):
	Global.active_set_index = set_options.get_selected_id()


func update_sets_index():
	# Set max index
	max_set_index = Global.set_list.size() - 1


func update_version_label():
	var txt = "v"
	txt += Global.version
	$FooterText/TitleText/VersionText.text = txt


##############################
  ### Button Handling ###
##############################

func update_sets_buttons():
	if Global.set_list.size() <= 1:
		btn_prev_set.disabled = true
		btn_next_set.disabled = true
	else:
		btn_prev_set.disabled = false
		btn_next_set.disabled = false


func _on_NewSessionButton_pressed():
	# Disable use if alerts or errors are present
	if Global.am_i_busy():
		return
	# Go to Scene
	if Global.get_sets_total() >= 1:
		Global.go_to_scene("res://Scenes/CreateSessionScene.tscn")

func _on_PrevSetButton_pressed():
	# Disable use if alerts or errors are present
	if Global.am_i_busy():
		return
	if Global.active_set_index == 0:
		Global.active_set_index = max_set_index
		set_options.select(Global.active_set_index)
	else:
		Global.active_set_index -= 1
		set_options.select(Global.active_set_index)


func _on_NextSetButton_pressed():
	# Disable use if alerts or errors are present
	if Global.am_i_busy():
		return
	if Global.active_set_index == max_set_index:
		Global.active_set_index = 0
		set_options.select(0)
	else:
		Global.active_set_index += 1
		set_options.select(Global.active_set_index)


func _on_CreateSetButton_pressed():
	# Disable use if alerts or errors are present
	if Global.am_i_busy():
		return
	# Go to Scene
	Global.go_to_scene("res://Scenes/CreateSetScene.tscn")


func _on_ModifySetButton_pressed():
	# Disable use if alerts or errors are present
	if Global.am_i_busy():
		return
	Global.go_to_scene("res://Scenes/ModifySetScene.tscn")


func _on_ViewTimesButton_pressed():
	# Disable use if alerts or errors are present
	if Global.am_i_busy():
		return
	Global.go_to_scene("res://Scenes/ViewTimeScene.tscn")


func _on_SettingsButton_pressed():
	# Disable use if alerts or errors are present
	if Global.am_i_busy():
		return
	Global.go_to_scene("res://Scenes/SettingsScene.tscn")


func _on_AboutButton_pressed():
	# Disable use if alerts or errors are present
	if Global.am_i_busy():
		return
	pass #! Replace with function body.


func _on_ExitButton_pressed():
	# Disable use if alerts or errors are present
	if Global.am_i_busy():
		return
	get_tree().quit()


func _on_TickerReset_timeout():
	$FooterText/TickerReset.start()
