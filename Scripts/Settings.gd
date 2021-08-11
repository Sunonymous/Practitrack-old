extends Node


# Declare member variables here. Examples:
const SAVE_PATH = "user://config.cfg"

var _config_file = ConfigFile.new()
var _settings = {
	"program": {
		"data_location": "DEFAULT",
		"pause_on_minimize": true,
		"save_with_active_timers": false,
		"instant_timer_deletion": false,
		#"max_interval_limit": 260
	},
	"display": {
		"use_time_letters": true,
		"display_zero_seconds": true
	},
	"integer": {
		"max_interval_limit": 260
	}
}
var _setting_type = {
	"data_location": null, #! Should not need to be configured here.
	"pause_on_minimize": "bool",
	"save_with_active_timers": "bool",
	"instant_timer_deletion": "bool",
	"max_interval_limit": "int",
	"use_time_letters": "bool",
	"display_zero_seconds": "bool"
}

# Called when the node enters the scene tree for the first time.
func _ready():
	load_settings()

func get_all_settings():
	# Returns the full settings for listing
	var formed = {}
	for group in _settings:
		formed[group] = {}
		for key in _settings[group].keys():
			formed[group][key] = get_value(group, key)
	return formed

func save_settings():
	for section in _settings.keys():
		for key in _settings[section]:
			_config_file.set_value(section, key, _settings[section][key])
	_config_file.save(SAVE_PATH)
	

func load_settings():
	var error = _config_file.load(SAVE_PATH)
	if error != OK:
		print("Failed loading settings file with error: ", error)
		return
	for section in _settings.keys():
		for key in _settings[section]:
			_config_file.get_value(section, key, null)
	

func get_value(section: String, setting: String):
	return _config_file.get_value(section, setting, null)


func set_value(section: String, setting: String, val):
	_settings[section][setting] = val
