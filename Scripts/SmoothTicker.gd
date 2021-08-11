extends RichTextLabel

## Credit https://gist.github.com/EricEzaM/ce60c60cb8e980b3150892b93ac14580
## by EricEzaM
  
# On the child (Label)
export (float) var scroll_speed = 60
var last_choice = 0
var version_notes = {
	"0.9": "new feature: automatic session creation",
	"0.92": "new feature: manual session creation"
} # Keep version notes here
var phrases = ["what will come next?",
  "we're not finished yet",
  "i have words in places i shouldn't...",
  "here to help you",
  "are you ready?",
  "now with flavor"
]


func _ready():
	# Move to right side of the screen
	rect_position.x += get_rect().size.x
	# Change Text
	text = select_new_text(true) # true for version note


func _process(delta):
	rect_position.x -= scroll_speed * delta
	if rect_position.x < -rect_size.x:
		rect_position.x = get_parent().get_rect().size.x
		text = select_new_text()


func select_new_text(version: bool = false):
	## Passing true selects the version note
	if version:
		return version_notes[Global.version]
	else:
		var index = last_choice
		while index == last_choice:
			index = int(rand_range(0, phrases.size()))
		last_choice = index
		return phrases[index]
