extends StaticBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

var frame_cnt=0
var fps = 2
var timer = 0

func get_class():
	return 'Lava'
	
func _ready():
	frame_cnt = randi()%4
	timer = randf()*1.0/fps
	
func _process(delta):
	timer += delta
	
	if timer > 1.0/fps:
		frame_cnt += 1
		frame_cnt %= 4
		
		get_node('Sprite').region_rect = Rect2(32*frame_cnt,0,32,32)
		timer = 0