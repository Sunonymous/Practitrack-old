extends Node2D

export (Vector2) var final_scale  = Vector2(1.5, 1.5)
export (float) var float_distance = 100
export (float) var duration = 0.5

func _ready():
	pop()


func pop():
	# Scale
	$Tween.interpolate_property(self, "scale", scale, final_scale \
		, duration, Tween.TRANS_BACK, Tween.EASE_IN_OUT)
	$Tween.start()
	yield($Tween, "tween_completed")
	# Float
	$Tween.interpolate_property(self, "position", position \
		, position + Vector2(0, -float_distance), duration, Tween.TRANS_BACK \
		, Tween.EASE_IN)
	$Tween.start()
	# Fade
	var transparent = modulate
	transparent.a = 0.0
	$Tween.interpolate_property(self, "modulate", modulate, transparent \
		, duration, Tween.TRANS_LINEAR, Tween.EASE_IN)
	$Tween.start()
	yield($Tween, "tween_completed")
	queue_free()
