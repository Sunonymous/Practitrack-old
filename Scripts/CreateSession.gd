extends Node2D




# Variables
var auto_max_items: int # Tracks how many items are in the selected set
var temp_items_copy: Array # Keeps a copy of the items in the local set to sort
var temp_item_addresses: Array = [] # A temporary container for item addresses

##
## Auto Nodes
onready var nd_set_options = $ScreenMarg/TabContainer/Automatic/AutoMarg/AutoVBox/SetVBox/SetOptions
onready var nd_auto_group_desc = $ScreenMarg/TabContainer/Automatic/AutoMarg/AutoVBox/DescHBox/GroupDescriptionText
onready var nd_auto_num_items_txt = $ScreenMarg/TabContainer/Automatic/AutoMarg/AutoVBox/NumItemsHBox/NumItemsText
## Line Edits
onready var nd_auto_num_items_lned = $ScreenMarg/TabContainer/Automatic/AutoMarg/AutoVBox/NumItemsHBox/NumItemsLned
onready var nd_auto_least_prac_lned = $ScreenMarg/TabContainer/Automatic/AutoMarg/AutoVBox/LPracHSplit/LPracLned
onready var nd_auto_rand_lned = $ScreenMarg/TabContainer/Automatic/AutoMarg/AutoVBox/RandHSplit/RandLned
## Buttons
onready var nd_auto_full_set_button = $ScreenMarg/TabContainer/Automatic/AutoMarg/AutoVBox/FullHSplit2/FullCkbtn
onready var nd_auto_rand_button = $ScreenMarg/TabContainer/Automatic/AutoMarg/AutoVBox/RandHSplit/RandCkbtn
onready var nd_auto_least_prac_button =  $ScreenMarg/TabContainer/Automatic/AutoMarg/AutoVBox/LPracHSplit/LPracCkbtn
##
## Manual Nodes
onready var nd_man_set_options = $ScreenMarg/TabContainer/Manual/ManMarg/ManVBox/SetHBox/OptionButton
onready var nd_man_set_items = $ScreenMarg/TabContainer/Manual/ManMarg/ManVBox/SetItemsHBox/SetItemList
onready var nd_man_sess_items = $ScreenMarg/TabContainer/Manual/ManMarg/ManVBox/SessItemsHBox/SessItemList
## Buttons
onready var nd_man_add_button = $ScreenMarg/TabContainer/Manual/ManMarg/ManVBox/TransButtonsHBox/AddItemButton
onready var nd_man_rem_button = $ScreenMarg/TabContainer/Manual/ManMarg/ManVBox/TransButtonsHBox/SubItemButton
onready var nd_man_back_button = $ScreenMarg/TabContainer/Manual/ManMarg/ManVBox/StartButtonsHBox/BackButton
onready var nd_man_start_button = $ScreenMarg/TabContainer/Manual/ManMarg/ManVBox/StartButtonsHBox/StartButton

class LeastPracticedSorter:
	# This holds the functions for sorting the items.
	static func sort_least_practiced(a, b):
		if a[2] > b[2]:
			return true
		return false



func _ready():
	# Set scene ref
	Global.active_scene_ref = self
	# Load possible sets
	for num in range(0, Global.get_sets_total()):
		nd_set_options.add_item(Global.get_set(num)["name"])
	# Set auto_max_items to number of items in set minus one
	auto_max_items = Global.get_number_of_items_in_set(nd_set_options.get_selected_id())
	# Update full set label to show item count
	$ScreenMarg/TabContainer/Automatic/AutoMarg/AutoVBox/FullHSplit2/FullText.text = \
		"Full Set? (%d items)" % Global.get_number_of_items_in_set(nd_set_options.get_selected_id())
	# Hide Least Practiced and Random Lneds to Start
	nd_auto_least_prac_lned.visible = false
	nd_auto_rand_lned.visible = false
	# Set buttons to default
	update_auto_buttons()
	update_auto_group_text()
	# Update Manual Page
	populate_manual_sets()
	nd_man_set_options.emit_signal("item_selected", Global.active_set_index)
	# Clear Session Build from Any Previous Sessions
	Global.session_items_build.clear()
	Global.session_mode = "()"


################################
### AUTO                     ###
################################

# Automatic mode offers Full Set, Random, or Least Practiced
# Full Set
# Least Practiced
# Randomize

func update_auto_buttons():
	# Updates the availability of buttons
	# If full set is checked, disable the others
	if nd_auto_full_set_button.pressed == true:
		nd_auto_rand_button.disabled = true
		nd_auto_rand_button.pressed = false
		nd_auto_least_prac_button.disabled = true
		nd_auto_least_prac_button.pressed = false
		nd_auto_num_items_lned.editable = false
		nd_auto_rand_lned.editable = false
		nd_auto_rand_lned.visible = false
		# Set lned to total number of items
		nd_auto_num_items_lned.text = str(Global.get_number_of_items_in_set(nd_set_options.get_selected_id()))
		update_auto_group_text()
	else:
		nd_auto_rand_button.disabled = false
		nd_auto_least_prac_button.disabled = false
		nd_auto_num_items_lned.editable = true
		nd_auto_rand_lned.editable = true


func update_auto_group_text():
	# Update text based on user specifications
	var text_to_add = ""
	if not nd_auto_full_set_button.pressed and \
	  nd_auto_num_items_lned.text != "" or \
	  nd_auto_least_prac_lned.text != "" or \
	  nd_auto_rand_lned.text != "":
		text_to_add += "You want to practice...\n"
	# Full Set
	if nd_auto_full_set_button.pressed == true:
		text_to_add += "You'd like to practice the [rainbow][wave amp=25 freq=3]full[/wave][/rainbow] set!"
		nd_auto_group_desc.parse_bbcode(text_to_add)
		return
	# Not Full Set
	# Random
	## Random Normal
	if nd_auto_rand_button.pressed and not nd_auto_least_prac_button.pressed:
		if nd_auto_rand_lned.text == "":
			var max_rand = 0
			if not nd_auto_full_set_button.pressed and not nd_auto_least_prac_button.pressed:
				max_rand = str(auto_max_items - 1)
			if nd_auto_least_prac_button.pressed and not nd_auto_full_set_button.pressed:
				max_rand = str(nd_auto_least_prac_lned.text)
			nd_auto_group_desc.parse_bbcode("Enter a quantity of random items no more than %s." % max_rand)
			return
		text_to_add += "A random %s item(s) out of the %s original." % [nd_auto_rand_lned.text, auto_max_items]
		nd_auto_group_desc.parse_bbcode(text_to_add)
		return
	## Least Practiced Normal
	if nd_auto_least_prac_button.pressed and not nd_auto_rand_button.pressed:
		if nd_auto_least_prac_lned.text == "":
			nd_auto_group_desc.parse_bbcode("Enter a quantity of items to practice no more than %s." % str(auto_max_items - 1))
			return
		text_to_add += "The %s least practiced items out of the %s original." % [nd_auto_least_prac_lned.text, auto_max_items]
		nd_auto_group_desc.parse_bbcode(text_to_add)
		return
	## Random Least Practiced
	if nd_auto_rand_button.pressed and nd_auto_least_prac_button.pressed:
		if nd_auto_least_prac_lned.text == "" or nd_auto_rand_lned.text == "":
			nd_auto_group_desc.parse_bbcode("Please enter a number of items in both boxes.")
			return
		text_to_add += "A random %s item(s) out of the %s least-practiced items." % [nd_auto_rand_lned.text, nd_auto_least_prac_lned.text]
		nd_auto_group_desc.parse_bbcode(text_to_add)
		return
	## Normal
	if not nd_auto_rand_button.pressed and not nd_auto_least_prac_button.pressed and not nd_auto_full_set_button.pressed and nd_auto_num_items_lned.text != "":
		text_to_add += "The first %s item(s) out of the original %d." % [nd_auto_num_items_lned.text, auto_max_items]
		nd_auto_group_desc.parse_bbcode(text_to_add)
		return
	## Nothing Selected
	if not nd_auto_rand_button.pressed and not nd_auto_least_prac_button.pressed and not nd_auto_full_set_button.pressed:
		text_to_add += "Make a selection for me to verify!"
		nd_auto_group_desc.parse_bbcode(text_to_add)
		return
	

func _on_StartAutoSessionButton_pressed():
	if nd_set_options.selected == -1:
		Global.alert("You must select a set to continue!", true) # true for error
		return
	if not acceptable_auto_session():
		Global.alert("Unable to start a session without items!", true) # true for error
		return
	# Start to add items and configure session
	Global.active_set_index = nd_set_options.get_selected_id()
	Global.session_uses_multi_sets = false
	Global.session_mode = Global.get_active_set()["mode"]
	# Clear and Re-Build the set index of addresses
	Global.session_items_build.clear()
	# Full Set
	## This is the only one which will not duplicate the array for processing
	if nd_auto_full_set_button.pressed:
		for num in range(0, Global.get_number_of_items_in_set(Global.active_set_index)):
			Global.session_items_build.append([Global.active_set_index, num])
		#! Global.go_to_scene("res://Scenes/SessionScene.tscn") #! remove if nothing is broken
	# All other modes
	else:
		temp_items_copy = Global.get_active_set()["items"].duplicate()
		# Temporarily add a third item to the addresses which contains the value
		for num in range(0, Global.get_active_set()["items"].size()):
			temp_item_addresses.append([Global.active_set_index, num, temp_items_copy[num][1]])
		# Normal Partial Set
		if not nd_auto_rand_button.pressed\
		  and not nd_auto_least_prac_button.pressed\
		  and not nd_auto_full_set_button.pressed:
			if temp_item_addresses[0].size() == 3: remove_value_in_addresses()
			for num in range(0, int(nd_auto_num_items_lned.text)):
				Global.session_items_build.append(temp_item_addresses[num])
		# If Least Practiced, sort the addressed
		if nd_auto_least_prac_button.pressed:
			temp_item_addresses.sort_custom(LeastPracticedSorter, "sort_least_practiced")
		## If not random, grab the number requested
		if not nd_auto_rand_button.pressed:
			if temp_item_addresses[0].size() == 3: remove_value_in_addresses()
			for num in range(0, int(nd_auto_least_prac_lned.text)):
				Global.session_items_build.append(temp_item_addresses[num])
		# Random
		## First we need to remove all addresses more than the number of rand
		if nd_auto_rand_button.pressed and nd_auto_least_prac_button.pressed:
			# Limit addresses to random lned
			var tmp_array = []
			for num in range(0, int(nd_auto_least_prac_lned.text)):
				tmp_array.append(temp_item_addresses[num])
			# Replace full temp item addresses with tmp_array
			temp_item_addresses = tmp_array
		if nd_auto_rand_button.pressed:
			# Shuffle the addresses
			temp_item_addresses.shuffle()
			temp_item_addresses.shuffle() # Shuffled twice for... extra random?
			if temp_item_addresses[0].size() == 3: remove_value_in_addresses()
			for num in range(0, int(nd_auto_rand_lned.text)):
				Global.session_items_build.append(temp_item_addresses[num])
		# Random from Least Practiced
	reset_temp_containers()
	Global.go_to_scene("res://Scenes/SessionScene.tscn")


func remove_value_in_addresses():
	# Removes the values added at the second index of temp_item_addresses
	for item in temp_item_addresses:
		item.remove(2)


func reset_temp_containers():
	# Clean up and leave
	temp_item_addresses.clear()
	temp_items_copy.clear()


func acceptable_auto_session():
	# Checks if all session criteria are valid
	# if number of items line is active
	if nd_auto_num_items_lned.visible == true:
		var nmi = int(nd_auto_num_items_lned.text)
		if contains_only_zeroes(str(nmi)): return false
		if nmi > auto_max_items: return false
	# Check least practiced
	if nd_auto_least_prac_button.pressed:
		var lp = int(nd_auto_least_prac_lned.text)
		if contains_only_zeroes(str(lp)): return false
		if lp > auto_max_items: return false
	# comparison with random in next branch
	# Check Random
	if nd_auto_rand_button.pressed:
		var rd = int(nd_auto_rand_lned.text)
		if contains_only_zeroes(str(rd)): return false
		if rd > auto_max_items - 1: return false
		if nd_auto_least_prac_button.pressed:
			if rd >= int(nd_auto_least_prac_lned.text): return false
	# if nothing else
	return true


func contains_only_zeroes(txt: String):
	if int(txt) == 0: return true
	else: return false



func _on_FullCkbtn_toggled(button_pressed):
	update_auto_buttons()
	if not button_pressed:
		nd_auto_num_items_lned.clear()
	update_auto_group_text()
	strike_out_num_text()


func _on_LPracCkbtn_toggled(button_pressed):
	if button_pressed:
		# Toggle Visibility of Least Practiced Line Edit
		nd_auto_least_prac_lned.visible = true
		nd_auto_least_prac_lned.text = nd_auto_num_items_lned.text
		# Hide number of items lned
		nd_auto_num_items_lned.visible = false
		nd_auto_num_items_lned.clear()
		
	else: # button ticked off
		# Copy text to num items
		nd_auto_num_items_lned.text = nd_auto_least_prac_lned.text
		nd_auto_least_prac_lned.clear()
		nd_auto_least_prac_lned.visible = false
		if not nd_auto_rand_button.pressed:
			nd_auto_num_items_lned.visible = true
	update_auto_group_text()
	strike_out_num_text()


func _on_RandCkbtn_toggled(button_pressed):
	# Hide number of items lned
	nd_auto_num_items_lned.visible = false
	if button_pressed:
		# Turn on Rand Line Edit
		nd_auto_rand_lned.visible = true
		# Uncheck Least Practiced, if On
		if not nd_auto_least_prac_button.pressed:
			# Copy value over from num items
			nd_auto_rand_lned.text = nd_auto_num_items_lned.text
			nd_auto_num_items_lned.clear()
		else: # if least prac is on
			# Toggle Visibility of Least Practiced Line Edit
			nd_auto_least_prac_lned.visible = true
	else: # button ticked off
		# Turn off Rand Line Edit
		if not nd_auto_least_prac_button.pressed:
			nd_auto_num_items_lned.text = nd_auto_rand_lned.text
		nd_auto_rand_lned.visible = false
		nd_auto_rand_lned.clear()
		if not nd_auto_least_prac_button.pressed:
			nd_auto_num_items_lned.visible = true
	update_auto_group_text()
	strike_out_num_text()


func only_accept_numbers(txt: String):
	# Sort the characters in the text and remove all but numbers
	var approved = ""
	for chara in txt:
		if chara.is_valid_integer(): approved += chara
	return approved


func more_than_max_items(txt: String):
	if txt == "":
		return ""
	# Takes the string from a line edit and verifies that it is not over limit
	if int(txt) > auto_max_items - 1:
		# Set to max and toggle full set on
		nd_auto_full_set_button.pressed = true
		nd_auto_full_set_button.emit_signal("toggled", nd_auto_full_set_button.pressed)
		return str(auto_max_items)
	else:
		return txt



func _on_NumItemsLned_focus_exited():
	var new_text = nd_auto_num_items_lned.text
	if new_text == "":
		return ""
	# Reject all but numbers
	new_text = only_accept_numbers(new_text)
	# Check if over the limit
	new_text = more_than_max_items(new_text)
	# Set text
	nd_auto_num_items_lned.text = new_text
	# Move cursor to end
	nd_auto_num_items_lned.set_cursor_position(nd_auto_num_items_lned.text.length())
	update_auto_group_text()


func _on_SetOptions_item_selected(index):
	var all_items = Global.get_number_of_items_in_set(index)
	# Set auto_max_items to number of items in set minus one
	auto_max_items = all_items
	# Update full set label to show item count
	$ScreenMarg/TabContainer/Automatic/AutoMarg/AutoVBox/FullHSplit2/FullText.text = \
		"Full Set? (%d items)" % all_items
	# If full set button is ticked, update num of items lned
	if $ScreenMarg/TabContainer/Automatic/AutoMarg/AutoVBox/FullHSplit2/FullCkbtn.pressed:
		$ScreenMarg/TabContainer/Automatic/AutoMarg/AutoVBox/NumItemsHBox/NumItemsLned.text = str(all_items)
	update_auto_group_text()


func _on_NumItemsLned_text_entered(_new_text):
	nd_auto_num_items_lned.emit_signal("focus_exited")


func _on_LPracLned_focus_exited():
	var new_text = nd_auto_least_prac_lned.text
	# Reject all but numbers
	new_text = only_accept_numbers(new_text)
	# Check if over the limit
	if int(new_text) > auto_max_items - 1:
		new_text = str(auto_max_items - 1)
	# Set text
	nd_auto_least_prac_lned.text = new_text
	# Move cursor to end
	nd_auto_least_prac_lned.set_cursor_position(nd_auto_num_items_lned.text.length())
	# If random is on, update random too
	if nd_auto_rand_button.pressed:
		nd_auto_rand_lned.emit_signal("focus_exited")
	update_auto_group_text()


func _on_LPracLned_text_entered(_new_text):
	nd_auto_least_prac_lned.emit_signal("focus_exited")


func _on_RandLned_focus_exited():
	var new_text = nd_auto_rand_lned.text
	# Reject all but numbers
	new_text = only_accept_numbers(new_text)
	# Check if over the limit
	if nd_auto_least_prac_button.pressed:
		if int(new_text) > int(nd_auto_least_prac_lned.text):
			new_text = nd_auto_least_prac_lned.text
		if int(new_text) == int(nd_auto_least_prac_lned.text):
			new_text = str(int(nd_auto_least_prac_lned.text) - 1)
	else:
		if int(new_text) > auto_max_items - 1:
			new_text = str(auto_max_items - 1)
		#Global.alert("There must be enough items practiced to randomize!", true) # true for error
	# Set text
	nd_auto_rand_lned.text = new_text
	# Move cursor to end
	nd_auto_rand_lned.set_cursor_position(nd_auto_num_items_lned.text.length())
	update_auto_group_text()


func _on_RandLned_text_entered(_new_text):
	nd_auto_rand_lned.emit_signal("focus_exited")


func _on_NumItemsLned_text_changed(new_text):
	new_text = only_accept_numbers(new_text)
	if int(new_text) < auto_max_items:
		update_auto_group_text()


func _on_LPracLned_text_changed(new_text):
	new_text = only_accept_numbers(new_text)
	if int(new_text) < auto_max_items - 1:
		update_auto_group_text()


func _on_RandLned_text_changed(new_text):
	new_text = only_accept_numbers(new_text)
	if nd_auto_least_prac_button.pressed:
		if int(new_text) < int(nd_auto_least_prac_lned.text):
			update_auto_group_text()
	else:
		if int(new_text) < auto_max_items - 1:
			update_auto_group_text()


func strike_out_num_text():
	# Checks to add a strikethrough to the number of items label to indicate
	#   that it is not needed
	if nd_auto_least_prac_button.pressed or nd_auto_rand_button.pressed:
		# One of the buttons is on, strike out the text
		nd_auto_num_items_txt.parse_bbcode("[s]Number of Items[/s]")
	else:
		# Both buttons off, text should be normal
		nd_auto_num_items_txt.parse_bbcode("Number of Items")


################################
### MANUAL                   ###
################################

# Manual mode has two windows. one to select from a list of sets,
#    and another that lists items to add.
# The bottom holds a container with the names of the items you're going to practice.

#
# Data
#

func populate_manual_sets():
	# Updates the list of sets for manual access
	nd_man_set_options.clear()
	for num in range(0, Global.get_sets_total()):
		nd_man_set_options.add_item(Global.get_set(num)["name"])


func populate_manual_set_items():
	# Updates the list of options within the sets on the manual tab
	nd_man_set_items.clear()
	for item in Global.get_active_set()["items"]: 
		nd_man_set_items.add_item(item[0])
	nd_man_set_items.unselect_all()


func populate_manual_session_items():
	# Updates the list of items queued for the session
	nd_man_sess_items.clear()
	for address in Global.session_items_build:
		nd_man_sess_items.add_item(Global.get_set(address[0])["items"][address[1]][0])
		#! Setting to Display item and set or just item


#
# Signals
#

func _on_OptionButton_item_selected(index):
	# Update the active set index and call the function to populate the items
	Global.active_set_index = index
	populate_manual_set_items()


func _on_AddItemButton_pressed():
	# Add the selected item from the set items box
	# Check if something is selected
	if not nd_man_set_items.is_anything_selected():
		Global.alert("Please select an item to add to the session.", true) # true for error
		return
	# Check if item is already present in the session
	var idx = nd_man_set_items.get_selected_items()[0]
	var set_num = Global.active_set_index
	for address in Global.session_items_build:
		if address[0] == set_num and address[1] == idx:
			Global.alert("Item is already queued for practice!", true) # true for error
			return
	# Supposedly we won't reach here unless it's not there already
	Global.session_items_build.append([Global.active_set_index, idx])
	nd_man_set_items.unselect_all()
	populate_manual_session_items()


func _on_SubItemButton_pressed():
	# Remove the selected item from the session items
	# Unselect anything in the set items box
	nd_man_set_items.unselect_all()
	# Check if anything is selected in the session items
	if not nd_man_sess_items.is_anything_selected():
		Global.alert("Please select an item to remove from the session items box.", true) # true for error
		return
	# If so, remove it
	Global.session_items_build.remove(nd_man_sess_items.get_selected_items()[0])
	# Repopulate list
	populate_manual_session_items()


func _on_StartButton_pressed():
	# Transition to session screen with the items added to session build in Global
	# Clear all the nodes
	nd_man_set_items.clear()
	nd_man_set_options.clear()
	nd_man_sess_items.clear()
	Global.session_mode = "Manual"
	Global.go_to_scene("res://Scenes/SessionScene.tscn")


func _on_BackButton_pressed():
	# Return to main menu
	Global.session_items_build.clear()
	Global.go_to_scene("res://Scenes/MainMenu.tscn")
