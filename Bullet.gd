extends Area2D

var state = 'play'
var state_timer = 0.0

var direction = Vector2(-1,0)
var speed = 300
var wait_time

func get_class():
	return 'Bullet'
	
func change_state(state):
	self.state = state
	state_timer = 0.0
	
	if(state == 'destroyed'):
		get_node('CollisionPolygon2D').disabled = true
		get_node('Polygon2D').visible = false
		get_node('Particles2D').emitting = false
		get_node('Particles2DDestroyed').restart()
		wait_time = get_node('Particles2DDestroyed').lifetime
	
func _process(delta):
	state_timer += delta
	
	if(state == 'play'):
		position += direction.normalized()*speed*delta
		
		var bodies = get_overlapping_bodies()
		for body in bodies:
				if body.get_class() == 'Me':
					change_state('destroyed')
					body.change_state('dying')
				elif body.get_class() == 'Family':
					if body.current_family_member == 'bro':
						body.shield(global_position-direction.normalized()*speed*2*delta)
						body.ext_velocity += direction.normalized() * speed/2
						change_state('destroyed')
					else:
						change_state('destroyed')
						body.change_state('dying')
				elif (body != get_parent()):
					change_state('destroyed')
		
		if global_position.x < -100 or global_position.x > 1124 or global_position.y<-100 or global_position.y>420:
			queue_free()
			
	elif(state == 'destroyed' and state_timer > wait_time):
		queue_free()