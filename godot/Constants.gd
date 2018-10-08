extends Node

#input configuration
const actions = ['ui_left','ui_right','ui_jump','ui_restart','ui_change','ui_pause'] 

#physics constants
const g = 1000.0

const family_dictionary = {'mom':0, 'dad':1, 'bro':2}
const family_color_dictionary = {'mom':Color('#e385c4'), 'dad':Color('#3f2cf0'), 'bro':Color('#146d17') }