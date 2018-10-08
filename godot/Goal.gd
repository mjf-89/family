extends Area2D

var state
var state_timer

func get_class():
	return 'Goal'
	
func _ready():
	change_state('waiting')
	
func change_state(state):
	self.state = state
	state_timer = 0.0
	
	if(state=='reached'):
		get_node('Particles2DWaiting').visible = false
		get_node("Particles2DReached").emitting = true
		change_state('completed')
	
	if(state=='failed'):
		get_node('Particles2DWaiting').emitting = false