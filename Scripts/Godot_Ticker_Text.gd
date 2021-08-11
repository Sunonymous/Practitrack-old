extends RichTextLabel

# Credits to EricEzaM on GitHub
# https://gist.github.com/EricEzaM/ce60c60cb8e980b3150892b93ac14580

# Tickers the text, but goes character by character instead of smoothly, like the previous script.
# extends Label

# All of the text to scroll
export (String) var ticker_text
# Number of characters to display
export (int) var num_chars_display = 9

const SPACES_TO_FILL_SCREEN = 35
var current_char_pos = 0
var text_length = 0 # will fail if doesn't load text on ready
var phrases = ["what will come next?", "i have words in places i shouldn't..."]
var choice = 0

# Keep version notes here
var version_notes = ["new feature: automatic session creation"]

func _ready():
	ticker_text = build_new_text(true) # true for version notes
	text_length = ticker_text.length()

# You could do this cleaner with a timer or something else, this is just quick and dirty
var cumulative_delta = 0
func _process(delta):
	cumulative_delta += delta
	if cumulative_delta > 0.1:
		set_ticker_text()
		cumulative_delta = 0
#	# Grab new text if screen is empty
#	if is_empty_and_long():
#		grab_new_text()


func build_new_text(version: bool = false):
	# Constructs a new string within many spaces.
	## Passing true makes it add the version notes
	var text_to_build = ""
	for num in range(0, SPACES_TO_FILL_SCREEN): text_to_build += "*"
	text_to_build += " "
	if version:
		text_to_build += version_notes[version_notes.size() - 1]
		text_to_build += " "
	else:
		text_to_build += phrases[int(rand_range(0, phrases.size() - 1))]
		text_to_build += " "
	for num in range(0, SPACES_TO_FILL_SCREEN * 3): text_to_build += "*"
	text_to_build += " "
	#!print("Debug - I built text")
	return text_to_build


func grab_new_text():
	# Get a new selection out of phrases
	ticker_text = build_new_text()


func set_ticker_text():
#	Set the text to the current position + some number of characters
	text = ticker_text.substr(current_char_pos, num_chars_display)
	
#	If there is overflow (meaning that "end" of the string is at a higher index than the length of the ticker text)
#	then loop back around and append the start of the text as needed
	if current_char_pos + num_chars_display > ticker_text.length():
		#print("Text overflow, looping")
		text += ticker_text.substr(0, current_char_pos + num_chars_display - ticker_text.length())

	current_char_pos += 1
# 	Mod the char position so it goes back to zero
	current_char_pos = current_char_pos % text_length


func _on_TickerReset_timeout():
	# grab new text
	print("Debug- timer resetarted")
	grab_new_text()
