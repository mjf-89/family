extends Container

var level_id = -1

func get_class():
	return 'LevelThumbnail'
	
func _on_Button_mouse_entered():
	if(not get_node('Locked').visible):
		get_node('Hover').visible = true
	
func _on_Button_mouse_exited():
	if(not get_node('Locked').visible):
		get_node('Hover').visible = false
	
func _on_Button_pressed():
	if(not get_node('Locked').visible):
		var main = self
		while(not main.has_method('goto_level')):
			main = main.get_parent()
		main.unpause()
		
		if main.lvl_id != level_id:
			main.goto_level(level_id)
		else:
			main.unpause()