extends KinematicBody2D

const Constants = preload('res://Constants.gd')

const speed_w = 100.0
const speed_j = 400.0
var velocity = Vector2()

var direction = 1
var bounce = false
var stop = false
var overhead = false
var climb =false

var state
var state_timer

var end = false
var prv_is_on_floor = false

func get_class():
	return 'Me'

func change_state(state):
	if self.state != 'dead':
		self.state = state
		state_timer = 0.0
		
		if(state=='dying'):
			get_parent().move_child(self,get_parent().get_child_count())
			get_node('CollisionPolygon2D').disabled = true
			get_node('Polygon2D').visible = false
			get_node('AnimatedSprite').visible = false
			get_node("Particles2D").emitting = true
			
			stop_sfx()
			get_node('SFX/fail').play()
			
			change_state('dead')
			
		if(state=='completed'):
			get_node('AnimatedSprite').stop()
			stop_sfx()
			
		if(state == 'appearing'):
			get_node('AnimatedSprite').visible = false
			get_node('AnimatedSprite').stop()
			get_node('Particles2DAppearing').emitting = true
			
		if(state == 'pause'):
			stop_sfx()
			
func stop_sfx():
	for sfx in get_node("SFX").get_children():
		sfx.stop()
		
func _ready():
	change_state('appearing')

func _physics_process(delta):
	state_timer += delta
	
	if(state == 'appearing'):
		if(state_timer>get_node('Particles2DAppearing').lifetime):
			get_node("AnimatedSprite").visible = true
		if(state_timer>get_node('Particles2DAppearing').lifetime*2):
			change_state('alive')
		
	elif(state == 'alive'):
		if end:
			move_end(delta)
		else:
			move(delta)
			
		if velocity.x!=0 and is_on_floor() or climb or overhead:
			get_node('AnimatedSprite').play()
		else:
			get_node('AnimatedSprite').frame = 1
			get_node('AnimatedSprite').stop()
		get_node('AnimatedSprite').flip_h = (direction == -1)
		
		if position.y > 320+100:
			change_state('dying')

func move(delta):
	#process collisions from previous move_and_slide
	bounce = false
	stop = false
	climb = false
	overhead = false
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)

		match collision.collider.get_class():
			'Lava':
				if collision.normal.x==0:
					change_state('dying')
			'Family':
				if collision.normal.y==0 and collision.normal.x*direction<0:
					match collision.collider.current_family_member:
						'mom':
							bounce = true
						'dad':
							stop = true
							climb = true
						'bro':
							stop = true
				if collision.normal==Vector2(0,-1):
					overhead = true
			'TileMap':
				if collision.normal.y==0 and collision.normal.x*direction<0:
					bounce = true
	
	#prepare velocity and direction for next move
	if is_on_floor():
		velocity.y = 0
	velocity.y += Constants.g*delta
	if climb:
		velocity.y = -speed_w
		
	if bounce:
		direction *= -1
	if stop :
		velocity.x = 0
	elif overhead and abs(get_floor_velocity().x)>speed_w and sign(get_floor_velocity().x) == direction:
		velocity.x = 0
	else:
		velocity.x = direction*speed_w
		
	#move
	move_and_slide(velocity, Vector2(0,-1), 0, 4, 0.8)
	
func move_end(delta):
	#process collisions from previous move_and_slide
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		
		match collision.collider.get_class():
			'Lava':
				if collision.normal.x==0 and collision.normal.y<0:
					change_state('dying')
					
	#prepare velocity and direction for next move
	if is_on_floor():
		velocity.y = 20
	elif is_on_ceiling():
		velocity.y = 0
	velocity.y += Constants.g*delta

	if Input.is_action_pressed('ui_jump') and is_on_floor():
		velocity.y = -speed_j

	velocity.x = 0
	if Input.is_action_pressed('ui_right'):
		velocity.x = speed_w*2
		direction = 1
	if Input.is_action_pressed('ui_left'):
		velocity.x = -speed_w*2
		direction = -1

	#move
	move_and_slide(velocity, Vector2(0,-1), 0, 4, 0.8)