tool
extends EditorProperty


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# The main control for editing the property.
var cimlist_control = preload("res://addons/LoveableEdit/cimlist.tscn").instance()
var control_list
# An internal value of the property.
# A guard against internal changes when the property is updated.
var updating = true


func _init(cim_initial):
#	control_list = cimlist_control.instance()

	# Add the control as a direct child of EditorProperty node.
	add_child(cimlist_control)
	# Make sure the control is able to retain the focus.
	add_focusable(cimlist_control)
	# Setup the initial state and connect to the signal to track changes.
	cimlist_control.set_cim(cim_initial)

func _on_button_pressed():
	# Ignore the signal if the property is currently being updated.
	if (updating):
		return


