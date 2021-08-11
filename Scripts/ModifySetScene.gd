extends Node2D

# Declare member variables here. Examples:
onready var conf_window = $DeleteMarginContainer/ConfirmationDialog
onready var items = $ScreenMarginCont/Panel/PanelMarCont/ContentVBox/ItemList
onready var line_edit = $ScreenMarginCont/Panel/PanelMarCont/ContentVBox/DetailsAddSplitter/AddItemLineEdit
onready var nd_sorting_menu = $ScreenMarginCont/Panel/PanelMarCont/ContentVBox/FormProcessButtonsCont/SortButton/SortingPopupMenu
onready var nd_sort_button = $ScreenMarginCont/Panel/PanelMarCont/ContentVBox/FormProcessButtonsCont/SortButton
onready var nd_edit_time_cont = $ScreenMarginCont/Panel/PanelMarCont/ContentVBox/EditTimeHBox
onready var nd_edit_time_line_edit = $ScreenMarginCont/Panel/PanelMarCont/ContentVBox/EditTimeHBox/TimeValLineEdit
onready var nd_deselect_item_button = $ScreenMarginCont/Panel/PanelMarCont/ContentVBox/DetailsAddSplitter/DeselectItemButton

var active_set_copy = {}
var edit_buttons_active = false
var edit_time_active = false
var sorting_functions = ["sort_ascending_name", "sort_descending_name", "sort_ascending_val", "sort_descending_val"]
var sorting_options = ["Ascending Name", "Descending Name", "Ascending Value", "Descending Value"]
const TIME_EDIT_MAX = 1000000000 # used to prevent values from going over this limit


class MyCustomSorter:
	# This holds the functions for sorting the sets.
	# [name, mode, [items]] Example Set
	static func sort_ascending_name(a, b):
		if a[0] < b[0]:
			return true
		return false
	static func sort_descending_name(a, b):
		if a[0] < b[0]:
			return false
		return true
	static func sort_ascending_val(a, b):
		if a[1] < b[1]:
			return true
		return false
	static func sort_descending_val(a, b):
		if a[1] < b[1]:
			return false
		return true


# Called when the node enters the scene tree for the first time.
func _ready():
	# Set to current scene
	Global.active_scene_ref = self
	# Copy selected set into local variant
	active_set_copy = Global.clone_active_set()
	#! Grab that variable, and use it to establish which mode is measured.
	#! Determine if data corresponds with that selected mode.
	# Populate the name field
	var name = active_set_copy["name"]
	$ScreenMarginCont/Panel/PanelMarCont/ContentVBox/FormTitle.text = name
	# Populate item list
	populate_item_list()
	# Populate sort menu
	populate_sort_menu()
	enable_disable_sorting()
	# Set Confirmation Cancel Signal to appropriate function
	conf_window.get_cancel().connect("pressed", self, "disconnect_confirmation_functions")


func populate_sort_menu():
	# Clear list
	nd_sorting_menu.clear()
	# Add items in optionsarray
	for op in sorting_options:
		nd_sorting_menu.add_item(op)


func populate_item_list():
	# Should be done every time an item is added or removed.
	# First clear list.
	items.clear()
	if active_set_copy["items"].size() != 0:
		# if there are any items, then we add them
		print("Populating item list.")
		# Temp string
		var txt_format = ""
		var time_format = ""
		var time_val = 0
		var txt_val = ""
		for num in range(0, active_set_copy["items"].size()):
			txt_format = "%d. %s"
			time_format = "(  %s  )"
			txt_val = txt_format % [num + 1, active_set_copy["items"][num][0]]
			if active_set_copy["mode"] == "Timer":
				time_val = Global.process_time(active_set_copy["items"][num][1])
			else:
				time_val = active_set_copy["items"][num][1]
			if edit_time_active:
				txt_val += "       "
				txt_val += time_format % [time_val]
			items.add_item( txt_val )


func _on_CancelButton_pressed():
	# Check no other actions are in progress
	if check_for_confirmation_window():
		return
	# Show confirmation window
	conf_window.window_title = "Are you sure you want to cancel changes to this set?"
	conf_window.popup_centered()
	conf_window.connect("confirmed", self, "cancel_set_and_return")


func cancel_set_and_return():
	# Return to menu
	Global.go_to_scene("res://Scenes/MainMenu.tscn")


func _on_AddItemButton_pressed():
	# If line edit is empty, skip
	if line_edit.text.strip_edges().length() <= 0:
		Global.alert("Items must have a name to be added.", true) # true for error
		clear_line_edit()
		return
	# Take the text in the AddItemLineEdit and add it to the array and to the list.
	var temp_array = []
	temp_array.append(line_edit.text)
	temp_array.append(0)
	active_set_copy["items"].append(temp_array)
	# Clear the line edit
	clear_line_edit()
	# Then repopulate the list.
	populate_item_list()
	enable_disable_sorting()


func enable_disable_sorting():
	# Disable / Enable sort button based on item count
	if items.get_item_count() > 1:
		nd_sort_button.disabled = false
	else:
		nd_sort_button.disabled = true


func _on_RemoveItemButton2_pressed():
	# If nothing is selected, skip
	if not items.is_anything_selected():
		Global.alert("No item is selected for removal.", true) # true for error
		return
	# Read the index of the selected line
	var idx_to_remove = items.get_selected_items()[0]
	# Remove the item in the copied set
	active_set_copy["items"].remove(idx_to_remove)
	# Repopulate the list
	populate_item_list()
	enable_disable_sorting()
	# Toggle Buttons
	if edit_buttons_active:
		toggle_button_sets()
	# Deselect Line
	items.unselect_all()
	# Clear line edit
	clear_line_edit()


func _on_ConfirmButton_pressed():
	# Check no other actions are in progress
	if check_for_confirmation_window():
		return
	# Show confirmation window
	conf_window.window_title = "Are you sure you want to save this set?"
	conf_window.popup_centered()
	conf_window.connect("confirmed", self, "save_new_set_and_return")


func save_new_set_and_return():
	# Replace the set using the copy
	Global.save_modified_set(active_set_copy)
	# Save to Disk
	Global.save_data()
	# Return to main menu
	Global.go_to_scene("res://Scenes/MainMenu.tscn")


func _on_AddItemLineEdit_text_entered(_new_text):
	# Grab button nodes
	var add_but = $ScreenMarginCont/Panel/PanelMarCont/ContentVBox/DetailsAddSplitter/AddItemButton
	if not edit_buttons_active:
		# If nothing is selected
		add_but.emit_signal("pressed")
	else:
		var save_but = $ScreenMarginCont/Panel/PanelMarCont/ContentVBox/DetailsAddSplitter/SaveItemButton
		var deselect_but = $ScreenMarginCont/Panel/PanelMarCont/ContentVBox/DetailsAddSplitter/DeselectItemButton
		# Editing active
		# Make sure something is selected
		if save_but.visible == true and items.is_anything_selected():
			save_but.emit_signal("pressed")
		if deselect_but.visible == true:
			deselect_but.emit_signal("pressed")


func toggle_button_sets():
	if edit_buttons_active:
		$ScreenMarginCont/Panel/PanelMarCont/ContentVBox/DetailsAddSplitter/SaveItemButton.visible = false
		$ScreenMarginCont/Panel/PanelMarCont/ContentVBox/DetailsAddSplitter/DeselectItemButton.visible = false
		$ScreenMarginCont/Panel/PanelMarCont/ContentVBox/DetailsAddSplitter/AddItemButton.visible = true
	else:
		$ScreenMarginCont/Panel/PanelMarCont/ContentVBox/DetailsAddSplitter/SaveItemButton.visible = true
		$ScreenMarginCont/Panel/PanelMarCont/ContentVBox/DetailsAddSplitter/DeselectItemButton.visible = true
		$ScreenMarginCont/Panel/PanelMarCont/ContentVBox/DetailsAddSplitter/AddItemButton.visible = false
	edit_buttons_active = not edit_buttons_active


func clear_line_edit():
	line_edit.clear()


func _on_ItemList_item_selected(index):
	# Return if editing time, because text is different
	#if edit_time_active:
	#	return
	# Toggle Buttons
	if not edit_buttons_active:
		toggle_button_sets()
	# Put item text in line edit
	line_edit.text = active_set_copy["items"][index][0] #items.get_item_text(index)
	line_edit.emit_signal("text_changed", line_edit.text)
	#! this next line might break something
	$ScreenMarginCont/Panel/PanelMarCont/ContentVBox/DetailsAddSplitter/SaveItemButton.visible = false


func _on_DeselectItemButton_pressed():
	# Toggle Buttons
	if edit_buttons_active:
		toggle_button_sets()
	# Deselect Line
	items.unselect_all()
	# Empty Line Edit
	clear_line_edit()


func _on_SaveItemButton_pressed():
	# Get text content
	var new_name = line_edit.text
	# Get item index
	var idx = items.get_selected_items()[0]
	# Replace item name
	active_set_copy["items"][idx][0] = new_name
	# Populate List
	populate_item_list()
	#! Toggle Button Sets
	toggle_button_sets()
	# Empty Line Edit
	clear_line_edit()


func _on_DeleteSetButton_pressed():
	if check_for_confirmation_window():
		return
	# Show confirmation window
	conf_window.window_title = "Are you sure you want to delete this set?"
	conf_window.popup_centered()
	conf_window.connect("confirmed", self, "delete_set_return_menu")


func disconnect_confirmation_functions():
	# Disconnects confirmation window functions
	if conf_window.is_connected("confirmed", self, "delete_set_return_menu"):
		conf_window.disconnect("confirmed", self, "delete_set_return_menu")
	if conf_window.is_connected("confirmed", self, "save_new_set_and_return"):
		conf_window.disconnect("confirmed", self, "save_new_set_and_return")
	if conf_window.is_connected("confirmed", self, "cancel_set_and_return"):
		conf_window.disconnect("confirmed", self, "cancel_set_and_return")
	conf_window.visible = false
	

func check_for_confirmation_window():
	# If window is not already open
	if $DeleteMarginContainer/ConfirmationDialog.visible == true:
		return true


func delete_set_return_menu():
	# Remove Set from Sets Data
	Global.remove_set(Global.active_set_index)
	Global.save_data()
	# Reset active_set_index to prevent nonfunctional buttons bug
	Global.active_set_index = 0
	Global.go_to_scene("res://Scenes/MainMenu.tscn")


func _on_AddItemLineEdit_text_changed(new_text):
	# If no item is selected, return
	if not items.is_anything_selected():
		return
	# If item name matches copy in set, show deselect button
	if new_text == active_set_copy["items"][items.get_selected_items()[0]][0]:
		$ScreenMarginCont/Panel/PanelMarCont/ContentVBox/DetailsAddSplitter/DeselectItemButton.visible = true
		$ScreenMarginCont/Panel/PanelMarCont/ContentVBox/DetailsAddSplitter/SaveItemButton.visible = false
	# If item is different, show save button
	if new_text != active_set_copy["items"][items.get_selected_items()[0]][0]:
		$ScreenMarginCont/Panel/PanelMarCont/ContentVBox/DetailsAddSplitter/DeselectItemButton.visible = false
		$ScreenMarginCont/Panel/PanelMarCont/ContentVBox/DetailsAddSplitter/SaveItemButton.visible = true


func _on_EditTimeButton_pressed():
	edit_time_active = not edit_time_active
	nd_edit_time_cont.visible = not nd_edit_time_cont.visible
	nd_deselect_item_button.emit_signal("pressed")
	populate_item_list()


func _on_SortButton_pressed():
	# Open popup menu
	nd_sorting_menu.popup_centered()


func _on_SortingPopupMenu_id_pressed(id):
	active_set_copy["items"].sort_custom(MyCustomSorter, sorting_functions[id])
	populate_item_list()


func _on_AddTimeValButton_pressed():
	# Check if anything is selected or written in the box
	if not items.is_anything_selected():
		# Display error
		Global.alert("No item selected.", true) # true for error
		return
	if nd_edit_time_line_edit.text == "":
		# Display error
		Global.alert("No time value is entered.", true) # true for error
		return
	# Check that time_val can be parsed into an integer
	var val = int(nd_edit_time_line_edit.text)
	# If doesn't exceed the limit, add
	var id = items.get_selected_items()[0]
	if active_set_copy["items"][id][1] + val <= TIME_EDIT_MAX:
		active_set_copy["items"][id][1] += val
	else:
		# Display error
		Global.alert("Time exceeds maximum capacity.", true) # true for error
		return
	# Clear fields, deselect item and repopulate list
	nd_edit_time_line_edit.clear() #! Could be a setting
	items.unselect_all()
	nd_deselect_item_button.emit_signal("pressed")
	populate_item_list()


func _on_SubTimeValButton_pressed():
	# Check if anything is selected or written in the box
	if not items.is_anything_selected():
		# Display error
		Global.alert("No item selected.", true) # true for error
		return
	if nd_edit_time_line_edit.text == "":
		# Display error
		Global.alert("No time value is entered.", true) # true for error
		return
	# Check that time_val can be parsed into an integer
	var val = int(nd_edit_time_line_edit.text)
	# If doesn't exceed the limit, add
	var id = items.get_selected_items()[0]
	if active_set_copy["items"][id][1] - val >= 0:
		active_set_copy["items"][id][1] -= val
	else:
		# Display error
		Global.alert("Time below minimum capacity.", true) # true for error
		return
	# Clear fields, deselect item and repopulate list
	nd_edit_time_line_edit.clear() #! Could be a setting
	items.unselect_all()
	nd_deselect_item_button.emit_signal("pressed")
	populate_item_list()


func _on_TimeValLineEdit_text_changed(new_text):
	# Sort the characters in the text and remove all but numbers
	var approved = ""
	for chara in new_text:
		if chara.is_valid_integer(): approved += chara
	nd_edit_time_line_edit.text = approved
	# Move cursor to end
	nd_edit_time_line_edit.set_cursor_position(nd_edit_time_line_edit.text.length())
