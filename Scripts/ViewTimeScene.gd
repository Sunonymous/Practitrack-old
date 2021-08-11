extends Node2D

#! Interpolate margin for title to create a floating effect.


# Member Variables
var sorting_functions = ["", "sort_ascending_name", "sort_descending_name", "sort_ascending_val", "sort_descending_val"]
var sorting_options = ["(Unsorted)", "Ascending Name", "Descending Name", "Ascending Value", "Descending Value"]
var sets_copy
var has_sorted = false

# Nodes
onready var set_options = $ScreenMargin/ScreenVBox/OptionMargin/HBoxContainer/SetOptionButton
onready var nd_sort_options = $ScreenMargin/ScreenVBox/OptionMargin/HBoxContainer/SortingOptionButton
onready var title = $ScreenMargin/ScreenVBox/TitleMargin/Title
onready var data_text = $ScreenMargin/ScreenVBox/DataMargin/DataText


class MyCustomSorter:
	# This holds the functions for sorting the items.
	static func sort_ascending_name(a, b):
		if a[0].to_lower() < b[0].to_lower():
			return true
		return false
	static func sort_descending_name(a, b):
		if a[0].to_lower() < b[0].to_lower():
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
	# Copy set into sets_copy
	if Global.get_sets_total() > 0:
		sets_copy = Global.clone_all_sets() # Used as local copy for manipulation
	update_title()
	populate_option_list()
	set_options.select(Global.active_set_index) # Display the active set as selected
	populate_sort_option_list()
	update_data()
	# Select the appropriate set
#	if Global.sets.size() > 0:
#		set_options.select(Global.active_set_index)



func populate_sort_option_list():
	# Clear list
	nd_sort_options.clear()
	# Add items in optionsarray
	for op in sorting_options:
		nd_sort_options.add_item(op)


func populate_option_list():
	# First clear list.
	set_options.clear()
	if Global.get_sets_total() != 0:
		# if there are any items, then we add them
		for num in range(0, Global.get_sets_total()):
			set_options.add_item(Global.get_set(num)["name"])


func update_title():
	# If there are no sets present, display this in the title
	var title_string = ""
	if Global.get_sets_total() <= 0:
		title_string = "[center]No Sets to View[/center]"
		title.parse_bbcode(title_string)
		return
	# Reorganize title to center with bbcode
	title_string = "[center]" + sets_copy[Global.active_set_index]["name"] + "[/center]"
	title.parse_bbcode(title_string)


func update_data():
	# Update Color
	data_text.set("modulate", Color(0, 0, 0))
	# Clear text
	data_text.clear()
	# Create temp string
	var text_str = ""
	# If there are no sets, set to default text
	if Global.get_sets_total() <= 0:
		data_text.parse_bbcode("[center]Nothing to see here...[/center]")
		nd_sort_options.visible = false
		set_options.visible = false
		return
	# If set has no items, display accordingly
	if sets_copy[Global.active_set_index]["items"].size() < 1:
		data_text.parse_bbcode("[center]No items in set.[/center]")
		nd_sort_options.visible = false
		return
	else:
		if nd_sort_options.visible == false:
			nd_sort_options.visible = true
	# For each individual item in the set
	for id in range(0, sets_copy[Global.active_set_index]["items"].size()):
		text_str += sets_copy[Global.active_set_index]["items"][id][0] # 0 is name
		# How the data is shown is determined by the mode
		if sets_copy[Global.active_set_index]["mode"] == "Timer":
			text_str += form_bb_text("right", Global.process_time(int(sets_copy[Global.active_set_index]["items"][id][1]))) # 1 is time
		else:
			var tmp_str = ""
			tmp_str += str(sets_copy[Global.active_set_index]["items"][id][1]) # 1 is time
			tmp_str += "  "
			text_str += form_bb_text("right", tmp_str)
		text_str += "\n\n"
		data_text.parse_bbcode(text_str)
		data_text.scroll_to_line(0)


func form_bb_text(tag, text):
	var format_str = "[%s]%s[/%s]"
	return format_str % [tag, text, tag]


func _on_ReturnButton_pressed():
	# Go back to main menu
	Global.go_to_scene("res://Scenes/MainMenu.tscn")


func _on_OptionButton_item_selected(index):
	Global.active_set_index = index
	update_title()
	update_data()


func _on_SortingOptionButton_item_selected(index):
	# Branch based on index
	if has_sorted:
		sets_copy[Global.active_set_index]["items"].sort_custom(MyCustomSorter, sorting_functions[index])
	else:
		nd_sort_options.remove_item(0)
		nd_sort_options.select(0) # this was causing a bug
		sorting_functions.remove(0)
		sorting_options.remove(0) # Not really needed, but why not?
		sets_copy[Global.active_set_index]["items"].sort_custom(MyCustomSorter, sorting_functions[index - 1])
		has_sorted = true
	update_data()
