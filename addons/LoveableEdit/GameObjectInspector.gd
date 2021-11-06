tool
extends EditorInspectorPlugin

signal show_thing_dock(object)
signal hide_thing_dock()
signal link_property(path, object)

var cimEditor = preload("res://addons/LoveableEdit/cim_property.gd")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func can_handle(object):
	if object is GameObject:
		emit_signal("show_thing_dock", object)
		print("Game Object")
		return true
	emit_signal("hide_thing_dock")
	return false

func parse_property(object, type, path, hint, hint_text, usage):
	if path=="cim":
		print(hint_text)
		#add_property_editor(path, cimEditor.new(0))
		emit_signal("link_property", path, object)
		return true
	else:
		return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
