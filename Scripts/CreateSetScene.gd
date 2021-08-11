extends Node2D

# Node References
onready var nd_mode_list = $ScreenMarginContainer/Panel/PanelMarginContainer/FullFormContainer/HelpFormDivider/FormFieldsDivider/FormFieldsContainer/ItemList
onready var name_input = $ScreenMarginContainer/Panel/PanelMarginContainer/FullFormContainer/HelpFormDivider/FormFieldsDivider/FormFieldsContainer/LineEdit

func _ready():
	# Set reference to current scene
	Global.active_scene_ref = self
	# Add items to mode list.
	for mode in Global.modes:
		nd_mode_list.add_item(mode)
	nd_mode_list.select(0)


### Data Functions



### Button Functions

func popup_help(title: String, txt: String):
	# Pop up the help window with the appropriate text.
	var nd_help_wind = $ScreenMarginContainer/Panel/HelpPopup
	var nd_help_txt = $ScreenMarginContainer/Panel/HelpPopup/RichTextLabel
	nd_help_wind.popup_centered()
	nd_help_wind.window_title = title
	nd_help_txt.text = txt



func _on_SetNameHelp_pressed():
	var help_title = "Set Name"
	var help_text = """
This is the name that a group of activities (the set) will have.
The items in the set can be changed at will, though the name of the set and the mode cannot currently be changed.
"""
	popup_help(help_title, help_text)


func _on_MeasureModeHelp_pressed():
	var help_title = "Measure Mode"
	var help_text = """
This determines how you measure your practice. It cannot be changed. Choose wisely!

Interval is the most flexible mode. It lets you add in easy-to-adjust intervals.

Timer is the most precise mode. It gives you the equivalent of a stopwatch to measure your time for each item.

Count is the simplest mode. It lets you increment your items by one."""
	popup_help(help_title, help_text)


func _on_ConfirmButton_pressed():
	if name_input.text.length() <= 0:
		# User has not entered a name.
		Global.alert("No name entered for set.", true)
		return
	Global.add_set(name_input.text.capitalize(), nd_mode_list.get_item_text(nd_mode_list.get_selected_items()[0]))
	# Reaching here assumes successful entry.
	Global.save_data()
	Global.load_data()
	# Change active_set_index to last index
	Global.active_set_index = Global.get_sets_total() - 1
	Global.go_to_scene("res://Scenes/ModifySetScene.tscn")


func _on_CancelButton_pressed():
	Global.go_to_scene("res://Scenes/MainMenu.tscn")
