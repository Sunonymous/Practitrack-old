extends ColorRect

## Credit https://gist.github.com/EricEzaM/ce60c60cb8e980b3150892b93ac14580
## by EricEzaM

# On the parent, e.g. ColorRect
# This gives this CanvasItem a "clipping mask" that only allows children to display within it's rect.
func _draw():
	VisualServer.canvas_item_set_clip(get_canvas_item(), true)
