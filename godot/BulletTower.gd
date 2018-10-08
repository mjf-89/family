extends StaticBody2D

export (float) var TIME_FIRE = 1.0
export (int) var N_BULLET = 1

export (float) var TIME_DELAY = 0.0
export (float) var TIME_WAIT = 0.0


export (Vector2) var direction = Vector2(1,0)
export (String,'normal','multiple','rotating','following') var type

const Bullet = preload('res://Bullet.tscn')

var level

var state
var state_timer = 0.0
var fire_cnt = 0

var rotating_direction = 1
var rotating_angle = -PI/4

var prv_me_position = Vector2()

func get_class():
	return 'BulletTower'
	
func _ready():
	change_state('delay')
	level = get_parent()
	while not (level.get_class() == 'Level'):
		level = level.get_parent()
		
		
func change_state(state):
	self.state = state
	state_timer = 0
	
	if(state == 'destroyed'):
		for child in get_children():
			if child.get_class() == 'Bullet':
				child.change_state('destroyed')
				
func fire(bullet):
	add_child(bullet)
	move_child(bullet,0)
	if not get_node('SFX/fire').playing:
		get_node('SFX/fire').play()
	
func _process(delta):
	state_timer += delta
	
	if state == 'delay' and state_timer >= TIME_DELAY :
		change_state('fire')
		
	if(state == 'wait' and state_timer >= TIME_WAIT):
		change_state('fire')
		
	if(state == 'fire'):
		if (state_timer<TIME_FIRE):
			if(state_timer>=TIME_FIRE/N_BULLET*fire_cnt):
				fire_cnt+=1
				match type:
					'normal':
						var new_bullet = Bullet.instance()
						new_bullet.direction = direction
						fire(new_bullet)
						
					'multiple':
						var rotated_direction = direction.rotated(PI/6)
						for i in range(3):
							var new_bullet = Bullet.instance()
							new_bullet.direction = rotated_direction
							rotated_direction = rotated_direction.rotated(-PI/6)
							fire(new_bullet)
					
					'rotating':
						rotating_angle += rotating_direction*PI/20
						if(abs(rotating_angle)>PI/4):
							rotating_direction *= -1
							
						var new_bullet = Bullet.instance()
						new_bullet.direction = direction.rotated(rotating_angle)
						
						fire(new_bullet)
					
					'following':
						if level.me.state == 'alive':
							var new_bullet = Bullet.instance()
							
							var me = level.me
							var dx = me.position.x - position.x
							var dy = me.position.y - position.y
							var vm = (me.position-prv_me_position)/delta
							
							var a = 1+pow(dy/dx,2)
							var b = -2*pow(dy/dx,2)*vm.x
							var c = pow(dy/dx*vm.x,2)-pow(new_bullet.speed,2)
							
							if dx>0:
								new_bullet.direction.x = (-b+sqrt(b*b-4*a*c))/(2*a)
							else:
								new_bullet.direction.x = (-b-sqrt(b*b-4*a*c))/(2*a)
							new_bullet.direction.y = sqrt(pow(new_bullet.speed,2) - pow(new_bullet.direction.x,2))
							new_bullet.direction = new_bullet.direction.normalized()
						
							fire(new_bullet)
		else:
			fire_cnt=0
			change_state('wait')
			
	prv_me_position = level.me.position
				