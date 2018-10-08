extends Sprite

var state_timer = 0
var state = 'hide'

var SHOW_TIME = 0.1

func get_class():
	return 'SpriteShield'
	
func change_state(state):
	state_timer = 0
	self.state = state

func _process(delta):
	state_timer += delta

	if(state == 'show' and state_timer<SHOW_TIME):
		visible = true
	else:
		visible = false