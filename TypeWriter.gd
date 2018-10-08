extends RichTextLabel

var speed = 20
export (float) var TIME_AFTERCOMPLETED = 1
export (String) var state = 'idle'
export (String) var translation_key = ''

var state_timer = 0.0
var append_time

func get_class():
	return 'TypeWriter'
	
func _ready():	
	translate()	
	visible_characters = 0

func _process(delta):
	state_timer += delta
	if(state == 'writing'):
		if(visible_characters <= text.length()):
			var current_char = ceil(state_timer*speed)
			if current_char < text.length() and text[current_char] == '\\':
				print('ops')
				current_char+=1
			visible_characters = current_char
		else:
			change_state('waiting')
			
	if(state == 'waiting') and state_timer>TIME_AFTERCOMPLETED:
		change_state('completed')

func skip():
	speed = 3000
	TIME_AFTERCOMPLETED = 0
	
func change_state(state):
	state_timer = 0.0
	self.state = state
	
	if(state == 'completed'):
		visible_characters = text.length()
		
func translate():
	if translation_key != '':
		bbcode_text = TranslationServer.tr(translation_key).c_unescape()
