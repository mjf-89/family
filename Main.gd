extends Node

const Constants = preload('res://Constants.gd')
const levels = [
preload('res://level_0.tscn'),
preload('res://level_1.tscn'),
preload('res://level_2.tscn'),
preload('res://level_3.tscn'),
preload('res://level_4.tscn'),
preload('res://level_5.tscn'),
preload('res://level_6.tscn'),
preload('res://level_7.tscn'),
preload('res://level_8.tscn'),
preload('res://level_9.tscn'),
preload('res://level_10.tscn'),
preload('res://level_11.tscn'),
preload('res://level_12.tscn'),
preload('res://level_13.tscn'),
preload('res://level_14.tscn'),
preload('res://level_15.tscn'),
preload('res://level_16.tscn'),
preload('res://level_17.tscn'),
preload('res://level_18.tscn'),
preload('res://level_19.tscn'),
preload('res://level_20.tscn'),
preload('res://level_21.tscn'),
preload('res://level_22.tscn'),
preload('res://level_23.tscn'),
preload('res://level_24.tscn'),
preload('res://level_25.tscn'),
preload('res://level_26.tscn'),
preload('res://level_27.tscn'),
preload('res://level_28.tscn'),
preload('res://level_29.tscn'),
preload('res://level_30.tscn'),
preload('res://level_end.tscn')
]

const credits=preload('res://credits.tscn')

var levels_thumb = []

var lvl_scene = null
var lvl_id = 0
var description = null

var state = 'splash'
var state_timer = 0.0

var play_time = 0.0
var rst_cnt = 0
var lvl_cnt = 0

var paused_nodes = []
var paused_states = []
var paused_state_timers = []

var ost = []
var ost_track_id = -1

var pause_node = null
var end = false
var credits_scene = null

var mjf = [false, false, false]

const TIME_SPLASH = 2

func get_class():
	return 'Main'
	
func _ready():
	var container = get_node('Pause/LevelsContainer/GridContainer')
	
	for i in range(levels.size()):
		var lvl_thumbnail = preload('res://LevelThumbnail.tscn').instance()
		if i==0:
			lvl_thumbnail.get_node('Label').text = 'Intro'
		elif i==levels.size()-1:
			lvl_thumbnail.get_node('Label').text = 'End'
		else:
			lvl_thumbnail.get_node('Label').text = 'Level %d'%i
		lvl_thumbnail.level_id = i
		
		levels_thumb.append(lvl_thumbnail)
		
		for member in get_level_family_members(i):
				match member:
					'mom':
						lvl_thumbnail.get_node("TextureMom").visible = true
					'dad':
						lvl_thumbnail.get_node("TextureDad").visible = true
					'bro':
						lvl_thumbnail.get_node("TextureBro").visible = true

		container.add_child(lvl_thumbnail)
		
	levels_thumb[0].get_node('Locked').visible = false
	
	load_progress()
	
	pause_node = get_node('Pause')
	remove_child(pause_node)
	pause_node.visible = true
	
	ost = get_node('OST').get_children()
	
	get_tree().set_auto_accept_quit(false)
	
func change_state(state):
	if(state == 'pause'):
		add_child(pause_node)
		
	if(self.state == 'pause' and state == 'play'):
		remove_child(pause_node)
		
	self.state = state
	state_timer = 0.0

func _process(delta):
	state_timer += delta
	play_time += delta
	
	if(ost_track_id == -1 or ost[ost_track_id].playing == false):
		ost_track_id += 1
		ost_track_id %= ost.size()
		ost[ost_track_id].play()

	if state == 'splash':
		if Input.is_key_pressed(KEY_M):
			mjf[0]=true
		if Input.is_key_pressed(KEY_J):
			mjf[1]=true
		if Input.is_key_pressed(KEY_F):
			mjf[2]=true
		
		if(mjf[0] and mjf[1] and mjf[2]):
			for i in range(levels_thumb.size()):
					levels_thumb[i].get_node('Locked').visible = false
				
	if state == 'splash' and state_timer>TIME_SPLASH:
		get_node('TextureRect').queue_free()
		goto_level(lvl_id)
		
	if state =='transition':
		if description != null:
			for action in Constants.actions:
				if Input.is_action_just_pressed(action):
					description.skip()

		if description == null or description.state=='completed':
			if description != null:
				remove_child(description)
				lvl_scene.add_child(description)
			add_child(lvl_scene)
			
			if lvl_scene.has_node('goal'):
				lvl_scene.move_child(lvl_scene.get_node('goal'),0)
			if lvl_scene.has_node('TileMap'):
				lvl_scene.move_child(lvl_scene.get_node('TileMap'),0)
			if lvl_scene.has_node('family'):
				lvl_scene.move_child(lvl_scene.get_node('family'),0)
			if lvl_scene.has_node('me'):
				lvl_scene.move_child(lvl_scene.get_node('me'),0)
			if lvl_scene.has_node('description'):
				lvl_scene.move_child(lvl_scene.get_node('description'),0)
			if lvl_scene.has_node('help'):
				lvl_scene.move_child(lvl_scene.get_node('help'),0)
			if lvl_scene.has_node('Light2DMoon'):
				lvl_scene.move_child(lvl_scene.get_node('Light2DMoon'),0)
				
			change_state('appearing')
			
	elif state == 'appearing' and lvl_scene.state == 'play':
		change_state('play')
		
	elif state == 'goal' and lvl_scene.state == 'completed':
		if not end:
			if (not levels_thumb[lvl_id].get_node('Completed').visible):
					lvl_cnt += 1
				
			levels_thumb[lvl_id].get_node('Completed').visible = true
			for i in range(min(lvl_cnt*2,levels_thumb.size())):
				levels_thumb[i].get_node('Locked').visible = false
		
		if lvl_id < levels.size()-1:
			if end and lvl_id == levels.size()-2:
				show_credits()
			else:
				next_level()
		elif lvl_id==levels.size()-1 and not end:
			end = true
			goto_level(0)
			
	elif state == 'play':
		if lvl_scene.me.state == 'dead':
			if not lvl_scene.has_node('family') or lvl_scene.has_node('family') and lvl_scene.family.state=='dead':
				lvl_scene.change_state('reload')
				change_state('reload')
		if Input.is_action_just_pressed('ui_restart'):
			lvl_scene.change_state('reload')
			change_state('reload')
			
		if lvl_scene.state=='goal':
			get_node('SFX/goal').play()
			change_state('goal')
			
	elif state ==  'reload':
		if lvl_scene.state=='failed':
			rst_cnt += 1
			reload_level()
			
	elif state == 'credits':
		if not credits_scene.get_node('AnimationPlayer').is_playing():
			remove_child(credits_scene)
			credits_scene.queue_free()
			end = false
			next_level()
		
	if Input.is_action_just_pressed('ui_pause') and not end:
		if(state == 'play'):
			pause(lvl_scene)
		elif(state == 'pause'):
			unpause()
				
func reload_level():
	if lvl_scene != null:
		lvl_scene.queue_free()
		lvl_scene = levels[lvl_id].instance()
		lvl_scene.end = end
		transition(true)
		
func next_level():
	goto_level(lvl_id+1)
		
func goto_level(id):
	var ss = OS.window_size
	ss.y = 320.0/1024*ss.x
	get_viewport().set_attach_to_screen_rect(Rect2(0.5*(OS.window_size-ss),ss))
	
	if lvl_scene != null:
		lvl_scene.queue_free()
		lvl_scene = null 
	
	lvl_id = id
	if(lvl_id < levels.size()):
		lvl_scene = levels[lvl_id].instance()
		lvl_scene.end = end
		transition()		
		
func transition(reload=false):
	if end:
		if lvl_scene.has_node('description'):
			description = lvl_scene.get_node('description')
			lvl_scene.remove_child(description)
			description.queue_free()
			description = null
		if lvl_scene.has_node('help'):
			var help = lvl_scene.get_node('help')
			lvl_scene.remove_child(help)
			help.queue_free()
	else:
		if lvl_scene.has_node('description'):
			description = lvl_scene.get_node('description')
			lvl_scene.remove_child(description)
			add_child(description)
			
			if lvl_id == levels.size()-1:
				var play_time_m = floor(play_time/60)
				var play_time_s = floor(play_time-play_time_m*60)
				var nz=0
				if(lvl_cnt+rst_cnt==0):
					nz = 1
				description.bbcode_text = TranslationServer.tr('DSC_LVL_END').c_unescape()%[(100.0*lvl_cnt/levels.size()),play_time_m,play_time_s,rst_cnt,(100.0*lvl_cnt/(lvl_cnt+rst_cnt+nz))]
			
			if(reload):
				description.change_state('completed')
			else:
				description.change_state('writing')
	
	change_state('transition')
		
func pause(node):
	for child in node.get_children():
		pause(child)
		
	if(node.get('state')):
		paused_nodes.push_back(node)
		paused_states.push_back(node.state)
		paused_state_timers.push_back(node.state_timer)
		
		node.change_state('pause')
	
	if state != 'pause':
		change_state('pause')
		
func unpause():
	for i in range(paused_nodes.size()):
		var node = paused_nodes.pop_back()
		node.change_state(paused_states.pop_back())
		node.state_timer = paused_state_timers.pop_back()
		
	change_state('play')
		
func get_level_family_members(id):
	var ss = levels[id].get_state()
	
	for i in ss.get_node_count():
		if ss.get_node_name(i) == 'family':
			return (ss.get_node_property_value(i,1))

	return []
	
func show_credits():
	var ss = OS.window_size
	ss.y = 320.0/1024*ss.x
	get_viewport().set_attach_to_screen_rect(Rect2(0.5*(OS.window_size-ss),ss))
	
	if lvl_scene != null:
		lvl_scene.queue_free()
		lvl_scene = null 
		
	credits_scene = credits.instance()
	add_child(credits_scene)
	
	change_state('credits')
	
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		if(state == 'play' and not end):
			call_deferred('pause',lvl_scene)

func quit():
		save_progress()
		
		if lvl_scene!=null:
			lvl_scene.queue_free()
		if pause_node!=null:
			pause_node.queue_free()
		queue_free()
		
		get_tree().quit()

func rst_progress():
	var dir = Directory.new()
	dir.remove('user://progress.json')
	
	if lvl_scene!=null:
		lvl_scene.queue_free()
	if pause_node!=null:
		pause_node.queue_free()
		
	get_tree().reload_current_scene()

func load_progress():
	var f_save = File.new()
	
	if f_save.file_exists('user://progress.json'):
		f_save.open('user://progress.json',File.READ)
		while not f_save.eof_reached():
			var data = parse_json(f_save.get_line())
			if f_save.eof_reached():
				break
			if not data.has('type'):
				continue
				
			match data['type']:
				'progress':
					play_time = data['v0']
					lvl_id = data['v1']
					lvl_cnt = data['v2']
					rst_cnt = data['v3']
					var lvl_completed = data['v4']
					for i in range(lvl_completed.size()):
						levels_thumb[i].get_node('Completed').visible = lvl_completed[i]
						if i < lvl_cnt*2:
							levels_thumb[i].get_node('Locked').visible = false
				'actmap':
					for ev in InputMap.get_action_list(data['act']):
						if ev.get_class() == 'InputEventKey':
							ev.scancode = data['key']
						elif ev.get_class() == 'InputEventJoypadButton':
							ev.button_index = data['joy']
				'locale':
					TranslationServer.set_locale(data['v'])
		f_save.close()

func save_progress():
	var lvl_completed = []
	for thm in levels_thumb:
		lvl_completed.push_back(thm.get_node('Completed').visible)
	
	var f_save = File.new()
	f_save.open('user://progress.json',File.WRITE)
	f_save.store_line(to_json({'type':'progress','v0':play_time, 'v1':lvl_id, 'v2':lvl_cnt, 'v3':rst_cnt, 'v4':lvl_completed}))
	for act in Constants.actions:
		var data = {'type':'actmap'}
		data['act']=act
		for ev in InputMap.get_action_list(act):
			if ev.get_class() == 'InputEventKey':
				data['key'] = ev.scancode
			elif ev.get_class() == 'InputEventJoypadButton':
				data['joy'] = ev.button_index
		f_save.store_line(to_json(data))
	f_save.store_line(to_json({'type':'locale','v':TranslationServer.get_locale()}))
	f_save.close()