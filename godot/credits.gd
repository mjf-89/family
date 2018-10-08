extends Node2D

func _ready():
	get_node('RichTextLabel').bbcode_text = TranslationServer.tr('CREDITS').c_unescape()
	get_node('RichTextLabel3').bbcode_text = TranslationServer.tr('CREDITS_THANKS').c_unescape()
	get_node('RichTextLabel4').bbcode_text = TranslationServer.tr('CREDITS_FIN').c_unescape()