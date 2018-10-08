extends Node2D

const TIME_AFTERCOMPLETED = 2.0

var me = null
var family = null
var goal = null
var map = null

var state = 'idle'
var state_timer = 0.0

var end = false

export (String) var description

func get_class():
	return 'Level'
	
func _ready():
	if(has_node('me')):
		me = get_node('me')
		if end :
			me.end = true
	if(has_node('family')):
		if end:
			get_node('family').queue_free()
		else:
			family = get_node('family')
	if(has_node('goal')):
		goal = get_node('goal')			
	if has_node('TileMap'):
		map = get_node('TileMap')
				
		var cells = map.get_used_cells_by_id(1)
		for cell in cells:
			var lava = preload('res://Lava.tscn').instance()
			lava.position = cell*16
			add_child(lava)
			map.set_cell(cell.x,cell.y,-1)
	
	change_state('appearing')
	
func change_state(state):
	self.state = state
	state_timer = 0
	
	if(state == 'appearing'):
		me.change_state('appearing')
		if(family!=null):
			family.change_state('appearing')
			family.direction = int(family.position.x < me.position.x)*2-1
			
		for child in map.get_children():
			if child.get_class()=='BulletTower':
				child.change_state('idle')
				
	if(state == 'play'):
		for child in map.get_children():
			if child.get_class()=='BulletTower':
				child.change_state('delay')
		
	if(state == 'goal' or state == 'reload'):
		for child in map.get_children():
			if child.get_class()=='BulletTower':
				child.change_state('destroyed')

func _process(delta):
	state_timer += delta
			
	if state == 'appearing' and me.state=='alive':
		change_state('play')
		
	if state=='play' and goal!=null:
		var bodies = goal.get_overlapping_bodies()
		for body in bodies:
			if body.get_class() == 'Me':
				if me != null:
					me.change_state('completed')
				if family != null:
					family.change_state('completed')

				goal.change_state('reached')
				change_state('goal')
				
	elif state=='goal':
		var vp = get_viewport()

		var ss = OS.window_size
		ss.y = 320.0/1024*ss.x
		
		var scale = 10
		
		var posA = 0.5*(OS.window_size-ss)
		var posB = -ss.x/1024*scale*(me.position)+ss/2
		var szA = ss
		var szB = ss*scale
		
		posB.x = min(posB.x, posA.x)
		posB.x = max(posB.x, ss.x*(1-scale))
		posB.y = min(posB.y, posA.y)
		posB.y = max(posB.y, ss.y*(1-scale))
		
		var p = state_timer/TIME_AFTERCOMPLETED
		
		var rec = Rect2(posA+posB*p,szA+(szB-szA)*p)
		vp.set_attach_to_screen_rect(rec)
		
		if state_timer > TIME_AFTERCOMPLETED:
			change_state('completed')
			
	elif state=='reload':
		if me != null:
			me.change_state('dying')
		if family != null:
			family.change_state('dying')
		if goal != null:
			goal.change_state('failed')
			
		if state_timer > TIME_AFTERCOMPLETED:
			change_state('failed')