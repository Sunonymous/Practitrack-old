extends Panel


# Declare member variables here. Examples:
var set_id
var item_id
var val = 0
var timer_active = false
var time = 0
var timer_string = ""
# Create variables for minutes and hours
var minutes = 0
var hours = 0
# Variable to increase before timer is deleted
var deletion_count = 0

# Nodes
#onready var nd_name = $Panel/HBoxContainer/ItemName
#onready var nd_val = $Panel/HBoxContainer/ItemValue
onready var nd_add = $HBoxContainer/AdjustButtons/AddButton
onready var nd_sub = $HBoxContainer/AdjustButtons/SubtractButton


# Called when the node enters the scene tree for the first time.
func _ready():
	#! Determine width to set this to based on size of main scene container
	# Disable or enable timers on minimize
	if Settings.get_value("program", "pause_on_minimize"):
		pause_mode = Node.PAUSE_MODE_STOP
	else:
		pause_mode = Node.PAUSE_MODE_PROCESS
	# Hide elements not needed
	if Global.get_set(set_id)["mode"] == "Interval":
		$HBoxContainer/AdjustButtons.visible = true
		$HBoxContainer/TimerButtons.visible = false
	if Global.get_set(set_id)["mode"] == "Timer":
		$HBoxContainer/TimerButtons.visible = true
		$HBoxContainer/AdjustButtons.visible = false
	if Global.get_set(set_id)["mode"] == "Count":
		$HBoxContainer/AdjustButtons.visible = true
		$HBoxContainer/TimerButtons.visible = false
	# Set value to 0
	update_val_label()
	update_label()
	# Update timer reset button tooltip based on setting
	if Settings.get_value("program", "instant_timer_deletion"):
		$HBoxContainer/TimerButtons/ClearButton.set("hint_tooltip", "Reset Timer")
	else:
		$HBoxContainer/TimerButtons/ClearButton.set("hint_tooltip", "Reset Timer (Push and hold)")


func get_item_mode():
	# Returns the mode for this particular item
	return Global.get_set(set_id)["mode"]


func save_to_set():
	# Save to slot in Global memory
	if Global.get_set_mode(set_id) == "Timer":
		Global.add_value_to_item(set_id, item_id, round(val))
	else:
		Global.add_value_to_item(set_id, item_id, val)


func update_label():
	var nd_name = $HBoxContainer/ItemName
	nd_name.text = Global.get_set(set_id)["items"][item_id][0]
	
	
func update_val_label():
	var nd_val = $HBoxContainer/ItemValue
	nd_val.text = str(val)
	

func update_time_label():
	var nd_val = $HBoxContainer/ItemValue
	nd_val.text = timer_string


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if timer_active:
		time += stepify(delta, 0.01)
		process_time()
		set_val_to_time()
	# Timer deletion
	if $HBoxContainer/TimerButtons/ClearButton.pressed == true:
		if Settings.get_value("program", "instant_timer_deletion"):
			# Delete timer
			delete_timer()
		else:
			deletion_count += delta
	else:
		deletion_count = 0
	# Delete timer if count is over 2
	if deletion_count >= 1.5:
		delete_timer()
		deletion_count = 0
		$HBoxContainer/TimerButtons/StartStopButton.text = "Start"


func set_val_to_time():
	val = time
	update_time_label()


func process_time():
	# Clear string
	timer_string = ""
	# If time is greater than 60, add a minute
	if time >= 60:
		minutes += 1
		time -= 60
	# If minutes are greater than 60, add an hour
	if minutes >= 60:
		hours += 1
		minutes -= 60
	# If hours have passed, add the count to the text
	if hours >= 1:
		timer_string += str(hours) + ":"
	# Leading zero for minutes
	if hours >= 1 and minutes <= 9:
		timer_string += "0"
	# If minutes have passed, add the count to text
	if minutes >= 1:
		timer_string += str(minutes) + ":"
	# Leading zero for seconds
	if minutes >= 1 and time <= 9.99:
		timer_string += "0"
	# Add the remaining time
	# Shorten it if longer than an hour
	timer_string += str(time)


func _on_SubtractButton_pressed():
	# If val is 0 or less, do nothing
	if val <= 0:
		return
	else:
		# Branch based on mode, if count only add one
		if get_item_mode() == "Count":
			val -= 1
		else: # Interval
			val -= Global.interval_value
	update_val_label()


func _on_AddButton_pressed():
	# If val is one billion or more, do nothing
	if val >= 1000000000:
		return
	else:
		# Branch based on mode, if count only add one
		if get_item_mode() == "Count":
			val += 1
		else: # Interval
			val += Global.interval_value
	update_val_label()


func _on_StartStopButton_pressed():
	#$HBoxContainer/TimerButtons/StartStopButton.theme.set_color(Color(1, 1, 1)) Gotta learn the code
	timer_active = not timer_active
	if timer_active:
		$HBoxContainer/TimerButtons/StartStopButton.text = "Stop"
		# Change text color to green
		self.add_color_override("custom_colors/font_color", Color(0.14,0.91,0))
		self.set("font_color",Color(0.14,0.91,0))
		self.add_color_override("font_color", Color(0.14,0.91,0))
	else:
		$HBoxContainer/TimerButtons/StartStopButton.text = "Start"
		# Change text color to red
		add_color_override("custom_colors/font_color", Color(0.39,0,0))
		set("font_color",Color(0.39,0,0))


func delete_timer():
	# Erase time value and update label
	timer_active = false
	time = 0
	set_val_to_time()
	timer_string = ""
	update_time_label()
