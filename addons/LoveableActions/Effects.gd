tool
extends VBoxContainer

const effect_entry = preload("res://addons/LoveableActions/EffectEntry.tscn")
onready var effects_list = $Scroll/EffectsList

var effect_entries = []
var editor_icons
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_update_effect_settings(effect_settings):
	for child in effects_list.get_children():
		effects_list.remove_child(child)
		print("Removing "+str(child))
		child.queue_free()
	var first = true
	for setting in effect_settings:
		if first:
			first = false
		else:
			effects_list.add_child(HSeparator.new())
			first = false
		var new_entry = effect_entry.instance()
		effects_list.add_child(new_entry)
		new_entry.set_icon_list(editor_icons)
		new_entry.process_property(setting)
		effect_entries.append(new_entry)
	
func set_icon_list(editor_icons_in):
	editor_icons = editor_icons_in
