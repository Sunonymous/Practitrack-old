extends Node2D


# Declare member variables here. Examples:
var ITEM_SCENE = preload("res://Scenes/ItemIndividual.tscn")
#onready var session_set_copy = Global.sets[Global.active_set_index] #! Can't really create a backup if using multiple sets.
onready var item_container = $ScreenPanel/ScreenMargCont/ContentVBox/ItemScrollContainer/VBoxContainer
onready var conf_window = $ConfirmationDialog

# Const Limits
const MAX_INTERVAL_VAL = 1000000


# Called when the node enters the scene tree for the first time.
func _ready():
	# Set to current scene
	Global.active_scene_ref = self
	# Set labels to Scene Name and Mode
	if Global.session_uses_multi_sets:
		$ScreenPanel/ScreenMargCont/ContentVBox/HeaderHBox/SessionTitle.text = "(Flex)" #! Add a loop that adds all sets from each item to a list
		#! Maybe hide mode text?
	else:
		$ScreenPanel/ScreenMargCont/ContentVBox/HeaderHBox/SessionTitle.text = Global.get_active_set()["name"]
	var mode_text = "[right]%s[/right]" 
	$"ScreenPanel/ScreenMargCont/ContentVBox/HeaderHBox/Mode&ToolContainer/SessionMode".parse_bbcode(mode_text % Global.session_mode)
	item_container.set_alignment(BoxContainer.ALIGN_CENTER)
	# Iterate through session build from Global.
	for idx in range(0, Global.session_items_build.size()):
		var item = ITEM_SCENE.instance()
		item.set_id = Global.session_items_build[idx][0]
		item.item_id = Global.session_items_build[idx][1]
		item.update_label()
		item_container.add_child(item)
	# Determine starting interval value, based on mode.
	# Based on mode, show or hide the following elements.
	#! This section is being rewritten to handle Manual mode
	match Global.session_mode:
		"Count":
			# If Count, interval_value is frozen at one. Hide Interval Adjustment.	
			Global.interval_value = 1
			$"ScreenPanel/ScreenMargCont/ContentVBox/HeaderHBox/Mode&ToolContainer/IntValMargin".visible = false
		"Interval":
			# If Interval, interval_value starts at five.
			Global.interval_value = 5
		"Timer":
			# If Timer, hide interval adjuster
			$"ScreenPanel/ScreenMargCont/ContentVBox/HeaderHBox/Mode&ToolContainer/IntValMargin".visible = false
		"Manual":
			pass
		_:
			print("Session match statement reached default.")	
	# Update Interval Value Label
	update_interval_value_label()


func _notification(what):
	# Check if program was minimized
	if what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		# App comes back
		get_tree().paused = false
	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		# App goes away
		get_tree().paused = true
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		# App is closed
		get_tree().paused = true
		pass


func update_interval_value_label():
	var val_text = "[center]" + str(Global.interval_value) + "[/center]"
	$"ScreenPanel/ScreenMargCont/ContentVBox/HeaderHBox/Mode&ToolContainer/IntValMargin/IntValHBox/IntValLabel".parse_bbcode(val_text)


func _on_IntValSubButton_pressed():
	# If interval is 1 or lower, do nothing
	if Global.interval_value <= 1:
		return
	# If interval is 5, set it to 1
	elif Global.interval_value == 5:
		Global.interval_value = 1
	# Otherwise, subtract five
	else:
		Global.interval_value -= 5
	# Update label
	update_interval_value_label()


func _on_IntValAddButton_pressed():
	# If interval is MAX_INTERVAL_VAL or higher, do nothing
	if Global.interval_value >= MAX_INTERVAL_VAL:
		return
	# If interval is 1, set to 5
	elif Global.interval_value == 1:
		Global.interval_value = 5
	# Otherwise add 5
	else:
		Global.interval_value += 5
	# Update label
	update_interval_value_label()


func _on_ConfirmButton_pressed():
	if conf_window.is_connected("confirmed", self, "cancel_changes_and_close"):
		conf_window.disconnect("confirmed", self, "cancel_changes_and_close")
	if not conf_window.is_connected("confirmed", self, "save_changes_and_close"):
		conf_window.connect("confirmed", self, "save_changes_and_close")
	conf_window.window_title = "Are you sure you want to save this session?"
	conf_window.popup_centered()


func _on_CancelButton_pressed():
	if conf_window.is_connected("confirmed", self, "save_changes_and_close"):
		conf_window.disconnect("confirmed", self, "save_changes_and_close")
	if not conf_window.is_connected("confirmed", self, "cancel_changes_and_close"):
		conf_window.connect("confirmed", self, "cancel_changes_and_close")
	conf_window.window_title = "Are you sure you want to cancel this session?"
	conf_window.popup_centered()
	

func save_changes_and_close():
	# Grab items container
	var items = $"ScreenPanel/ScreenMargCont/ContentVBox/ItemScrollContainer/VBoxContainer"
	#! Debug add confirmation
	#! Confirm with active timers?
	#! Check and tie in to global mode variable
	if Global.session_mode == "Timer" or Global.session_mode == "Manual":
		# if setting requires
		if not Settings.get_value("program", "save_with_active_timers"):
			for _item in items.get_children():
				if _item.timer_active:
					Global.alert("Cannot finish session with active timers.", true) # true for error
					return
	for _item in items.get_children():
		_item.save_to_set()
	Global.save_data()
	# Reset session mode
	Global.session_mode = ""
	Global.session_items_build.clear()
	Global.go_to_scene("res://Scenes/MainMenu.tscn")


func cancel_changes_and_close():
	# Not much to say here
	Global.go_to_scene("res://Scenes/MainMenu.tscn")


func check_for_confirmation_window():
	# If window is not already open
	if $ConfirmationDialog.visible == true:
		return true
