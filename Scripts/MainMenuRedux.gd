extends Node2D

onready var set_btn_nd = $SetBox/PathFollow2D/SetsPolygon/SetsButton
onready var set_tween_nd = $SetBox/PathFollow2D/RotTween

var sets_menu_open: bool = false # used to toggle opening the sets menu

func update_version_label():
	var txt = "[right]v"
	txt += Global.version
	txt += "[/right]"
	var _error = $FooterText/TitleText/VersionText.parse_bbcode(txt)



func _on_SetsButton_pressed():
	if not sets_menu_open:
		set_tween_nd.interpolate_property($SetBox/PathFollow2D, "unit_offset",
			0, 1, 0.25, Tween.TRANS_LINEAR, Tween.TRANS_LINEAR)
		set_tween_nd.interpolate_property($SetBox/PathFollow2D/SetsPolygon, "polygon_rotation",
			0, 90, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	if sets_menu_open:
		set_tween_nd.interpolate_property($SetBox/PathFollow2D, "unit_offset",
			1, 0, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
		set_tween_nd.interpolate_property($SetBox/PathFollow2D/SetsPolygon, "polygon_rotation",
			90, 0, 0.25, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	set_tween_nd.start()
	sets_menu_open = not sets_menu_open
	yield(get_tree().create_timer(0.3), "timeout")
	print("BLIP")
