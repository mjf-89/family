extends Button

const Constants = preload('res://Constants.gd')

export (String) var action

var display_joy = false

func get_class():
	return 'ButtonKeyConf'
	
func _enter_tree():
	display_joy = check_joy()
	display_text()
	
func _process(delta):
	if check_joy() != display_joy:
		display_joy = not display_joy
		display_text()
	
func check_joy():
	var check=false
	if Input.get_connected_joypads().size()>0:
		for joy_id in Input.get_connected_joypads():
			if Input.is_joy_known(joy_id):
				check = true
				
	return check
	
func display_text():
	var event_list = InputMap.get_action_list(action)
	var event
	
	for ev in event_list:
		event = ev
		if display_joy == true:
			if ev is InputEventJoypadButton:
				break
		else:
			if ev is InputEventKey:
				break

	text = get_event_str(event)

func get_event_str(event):
	var chr = ''
	
	if(event is InputEventKey):
		match event.scancode:
			KEY_LEFT:
				chr = '<'
			KEY_RIGHT:
				chr = '>'
			KEY_UP:
				chr = '^'
			KEY_DOWN:
				chr = '/'
			_:
				chr = OS.get_scancode_string(event.scancode)
				if(chr.length()>1):
					chr = chr.to_lower()
		
	if(event is InputEventJoypadButton):
		match Input.get_joy_button_string(event.button_index):
			'DPAD Left':
				chr = '<'
			'DPAD Right':
				chr = '>'
			'DPAD Up':
				chr = '^'
			'DPAD Down':
				chr = '/'
			'Face Button Top':
				chr = 'jY'
			'Face Button Bottom':
				chr = 'jA'
			'Face Button Left':
				chr = 'jX'
			'Face Button Right':
				chr = 'jB'
			'Start':
				chr = 'strt'
			'Select':
				chr = 'sel'
			'L','L2','R','R2':
				chr = 'j'+Input.get_joy_button_string(event.button_index)
			_:
				chr = "J%d"%event.button_index

	return chr
	
func _input(event):
	if(pressed):
		if(event is InputEventKey or event is InputEventJoypadButton):
			var used = false
			for act in Constants.actions:
				if InputMap.event_is_action(event,act):
					used = true

			if not used:
				for set_event in InputMap.get_action_list(action):
					if event.get_class() == set_event.get_class():
						InputMap.action_erase_event(action,set_event)
						break

				InputMap.action_add_event(action,event)

				display_text()

			pressed = false