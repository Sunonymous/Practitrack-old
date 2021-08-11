extends RichTextLabel

var active:bool = true
var expanding:bool = true
var mouse_over:bool = false
var tick: float = 0.0
var outline_size:int = 0
export var txt: String
export var fx: String
export (Array, String) var params
export var TICK_LIMIT: float = 0.11
export var MAX_OUTLINE:int = 6
export var MIN_OUTLINE:int = 0
export var TIME_DELAY = 5.5
onready var timer = $ResetTimer
onready var font


func _ready():
	txt = self.get_bbcode()	
	timer.set("wait_time", TIME_DELAY)
	# If font isn't behaving as expected, make it a unique reference/resource in editor
	font = self.get("custom_fonts/normal_font")
	$Button.rect_size.x = self.rect_size.x
	$Button.rect_size.y = self.rect_size.y


func _process(delta):
	tick += delta
	if tick > TICK_LIMIT:
		if active:
			outline_size = font.get("outline_size")
			if expanding:
				if outline_size < MAX_OUTLINE: font.set("outline_size", outline_size + 1)
				#else:
					#if timer.is_stopped(): timer.start()
			else: # Contracting
				if outline_size > MIN_OUTLINE: font.set("outline_size", outline_size - 1)
			if timer.is_stopped(): timer.start()
		tick = 0

func _on_ResetTimer_timeout():
	expanding = not expanding


func update_label():
	var _error
	if mouse_over:
		# build the fx
		var fx_with_params = fx + " "
		for effect in params:
			fx_with_params  += effect
			fx_with_params += " "
		_error = self.parse_bbcode("[%s]%s[/%s]" % [fx_with_params, txt, fx])
	else:
		_error = self.parse_bbcode(txt)


func _on_SessionBTNText_mouse_entered():
	mouse_over = true
	update_label()


func _on_SessionBTNText_mouse_exited():
	mouse_over = false
	update_label()


func _on_ControlParent_pressed():
	print("boop")
