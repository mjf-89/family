extends KinematicBody2D

const Constants = preload("res://Constants.gd")

var state
var state_timer

export (Array) var family_members
var current_family_member
var current_family_id=-1

#physics related variables
const speed_j = 400.0
const speed_w = 200.0
var velocity = Vector2()
var direction = 1

var prv_is_on_floor = false
var falling = false

var ext_velocity = Vector2()

var release_jmp_key_pause = true

func get_class():
	return 'Family'
	
func change_state(state):
	if self.state != 'dead':
		self.state = state
		state_timer = 0.0
		
		if(state=='dying'):
			get_parent().move_child(self,get_parent().get_child_count())
			get_node('CollisionPolygon2D').disabled = true
			get_node('Polygon2D').visible = false
			get_node('AnimatedSprite').visible = false
			get_node('SpriteShield').visible = false
			get_node("Particles2D").emitting = true
			get_node('Particles2D').process_material.color = Constants.family_color_dictionary[current_family_member]
			
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
			get_node('Particles2DAppearing').process_material.color = Constants.family_color_dictionary[current_family_member]
			get_node('Particles2DAppearing').process_material.color.a8 = 120
			
		if(state == 'pause'):
			stop_sfx()
			release_jmp_key_pause = false
			
func stop_sfx():
	for sfx in get_node("SFX").get_children():
		sfx.stop()

func change_family_member(animate=false):
	current_family_id += 1
	current_family_id %= family_members.size()
	current_family_member = family_members[current_family_id]
	get_node('AnimatedSprite').animation = current_family_member
	
	get_node('Polygon2D').color = Constants.family_color_dictionary[current_family_member]
	if(animate and family_members.size()>1):
		get_node('Particles2DChange').restart()

func _ready():
	change_family_member()
	change_state('appearing')

func _physics_process(delta):
	state_timer += delta
	
	if(state == 'appearing'):
		if(state_timer>get_node('Particles2DAppearing').lifetime):
			get_node("AnimatedSprite").visible = true
		if(state_timer>get_node('Particles2DAppearing').lifetime*2):
			change_state('alive')
	elif state == 'alive':
		move(delta)
		
		#animations and sfx
		if is_on_floor() and not prv_is_on_floor and velocity.y>100:
			get_node('SFX/land').play()
		elif not is_on_floor() and prv_is_on_floor and velocity.y==-speed_j:
			get_node('SFX/jump').play()
			
		if velocity.x!=0 and is_on_floor():
			get_node('AnimatedSprite').play()
			if not get_node('SFX/walk').playing:
				get_node('SFX/walk').play()
		else:
			get_node('AnimatedSprite').frame = 1
			get_node('AnimatedSprite').stop()
			get_node('SFX/walk').stop()
			
		if Input.is_action_just_pressed('ui_change'):
			change_family_member(true)
			
		if position.y > 320+100:
			change_state('dying')

	get_node('AnimatedSprite').flip_h = (direction<0)
	
func move(delta):
	#process collisions from previous move_and_slide
	var stop = false
	var overhead = false
	for i in range(get_slide_count()):
		var collision = get_slide_collision(i)
		
		match collision.collider.get_class():
			'Lava':
				if collision.normal.x==0 and collision.normal.y<0 and current_family_member!='bro':
					change_state('dying')
				elif collision.normal.x==0 and collision.normal.y<0 and current_family_member=='bro':
					shield(global_position+Vector2(0,16),false)
			'Me':
				if collision.normal==Vector2(0,-1) and collision.collider.velocity.x!=0:
					overhead = true
					
	#prepare velocity and direction for next move
	if is_on_floor():
		velocity.y = 20
	elif is_on_ceiling():
		velocity.y = 0
	velocity.y += Constants.g*delta

	if not release_jmp_key_pause and not Input.is_action_pressed('ui_jump'):
		release_jmp_key_pause = true
		
	if Input.is_action_pressed('ui_jump') and is_on_floor() and release_jmp_key_pause:
		var blocked = false
		if get_node('Area2DJumpPrevention').get_overlapping_bodies().size()>0:
			blocked = true 			
		if not blocked:
			velocity.y = -speed_j

	velocity.x = 0
	if Input.is_action_pressed('ui_right'):
		velocity.x = speed_w
		direction = 1
	if Input.is_action_pressed('ui_left'):
		velocity.x = -speed_w
		direction = -1
		
	elif(overhead):
		if abs(get_floor_velocity().x)==0:
			velocity.y = -20
		if velocity.x != 0:
			velocity.x -= get_floor_velocity().x
			
	velocity += ext_velocity
	ext_velocity = Vector2()

	#move
	prv_is_on_floor = is_on_floor()
	move_and_slide(velocity, Vector2(0,-1), 0, 4, 0.8)
	
func shield(bullet_position, sfx=true):
	if(sfx):
		get_node('SFX/protect').play()
	get_node('SpriteShield').change_state('show')
	get_node('SpriteShield').look_at(bullet_position)
	