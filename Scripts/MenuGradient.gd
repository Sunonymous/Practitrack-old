extends TextureProgress

var active: bool = false
var mouse_over: bool = false


func _process(_delta):
	if active:
		if value < max_value:
			value += 10
		else:
			if $ResetTimer.is_stopped() and not mouse_over:
				$ResetTimer.start()
	else:
		if value > min_value:
			value -= 20


func _on_TextureProgress_mouse_entered():
	if not active and $ResetTimer.is_stopped():
		active = true
	mouse_over = true
	

func _on_ResetTimer_timeout():
	active = false
	#value = 0
	$ResetTimer.stop()


func _on_TextureProgress_mouse_exited():
	mouse_over = false
