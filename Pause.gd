extends Node2D

var lvl_container = null
var focus = -1

func get_class():
	return 'Pause'

func _ready():		
	lvl_container = get_node("LevelsContainer/GridContainer")

func _enter_tree():
	if(TranslationServer.get_locale().begins_with('it')):
		get_node('ButtonITA').add_color_override("font_color", Color('#ffffff'))
		get_node('ButtonENG').add_color_override("font_color", Color('#8a8a8a'))
	else:
		get_node('ButtonENG').add_color_override("font_color", Color('#ffffff'))
		get_node('ButtonITA').add_color_override("font_color", Color('#8a8a8a'))
		
	if(lvl_container!=null):
		unfocus()
		focus(get_parent().lvl_id)

func _on_ButtonQuit_pressed():
	get_parent().quit()

func unfocus():
	for thm in lvl_container.get_children():
		thm._on_Button_mouse_exited()
		
func focus(id):
	if not lvl_container.get_child(id).get_node('Locked').visible:
		if focus>=0:
			lvl_container.get_child(focus)._on_Button_mouse_exited()
		lvl_container.get_child(id)._on_Button_mouse_entered()
		focus = id
		
		var scr_cnt_rect = lvl_container.get_parent().get_rect()
		var grd_cnt_rect = lvl_container.get_rect()
		var thm_cnt_rect = lvl_container.get_child(id).get_rect()
		
		grd_cnt_rect.position.y*=-1
		grd_cnt_rect.size = scr_cnt_rect.size
		
		if thm_cnt_rect.end.y>grd_cnt_rect.end.y:
			lvl_container.get_parent().scroll_vertical += thm_cnt_rect.end.y-grd_cnt_rect.end.y
		elif thm_cnt_rect.position.y<grd_cnt_rect.position.y:
			lvl_container.get_parent().scroll_vertical += thm_cnt_rect.position.y-grd_cnt_rect.position.y

func _process(delta):
	var new_focus = focus
		
	if Input.is_action_just_pressed('ui_left'):
		if new_focus < 0:
			new_focus = 0
		else:
			new_focus -= 1
	elif Input.is_action_just_pressed('ui_right'):
		if new_focus < 0:
			new_focus = 0
		else:
			new_focus += 1
		
	if new_focus<0 or new_focus>lvl_container.get_child_count()-1:
		new_focus = focus
		
	if new_focus != focus:
		focus(new_focus)
	
	if Input.is_action_just_pressed('ui_jump') or Input.is_action_just_pressed('ui_accept'):
		if focus>=0:
			get_node("LevelsContainer/GridContainer").get_child(focus)._on_Button_pressed()

func _on_ButtonITA_pressed():
	TranslationServer.set_locale('it_IT')
	get_parent().lvl_scene.get_node('description').translate()
	get_node('ButtonITA').add_color_override("font_color", Color('#ffffff'))
	get_node('ButtonENG').add_color_override("font_color", Color('#8a8a8a'))
	
func _on_ButtonENG_pressed():
	TranslationServer.set_locale('en_US')
	get_parent().lvl_scene.get_node('description').translate()
	get_node('ButtonENG').add_color_override("font_color", Color('#ffffff'))
	get_node('ButtonITA').add_color_override("font_color", Color('#8a8a8a'))

func _on_ButtonFullscreen_toggled(button_pressed):
	if not button_pressed :
		OS.window_fullscreen = false
		OS.window_size = Vector2(1024,320)
	else:
		OS.window_fullscreen = true

func _on_TextureButton_toggled(button_pressed):
	var bus_id = AudioServer.get_bus_index('Master')
	
	if not button_pressed :
		AudioServer.set_bus_mute(bus_id,false)
	else:
		AudioServer.set_bus_mute(bus_id,true)

func _on_ButtonReset_pressed():
	get_parent().rst_progress()