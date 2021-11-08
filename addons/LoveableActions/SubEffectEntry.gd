tool
extends HBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var sub_label = $SubEffectLabel

var property_info
var edit_node
var edited_action
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func process_property(prop):
	property_info = prop
	sub_label.text = prop.name
	var new_edit
	if prop.type == TYPE_STRING:
		new_edit = LineEdit.new()
	elif prop.type == TYPE_INT:
		new_edit = SpinBox.new()
		new_edit.step = 1
	elif prop.type == TYPE_REAL:
		new_edit = SpinBox.new()
		new_edit.step = 0.01
	new_edit.size_flags_horizontal |= SIZE_EXPAND 

	edit_node = new_edit
	add_child(edit_node)
	
func change_edited_action(next_edited_action):
	edited_action = next_edited_action

func set_sub_effect_data():
	var sub_effect_payload
	if property_info.type == TYPE_STRING:
		sub_effect_payload = edit_node.text
		if sub_effect_payload == "":
			edit_node.grab_focus()
			return false
	elif property_info.type == TYPE_INT or property_info.type == TYPE_REAL:
		sub_effect_payload = edit_node.value
		if not sub_effect_payload:
			edit_node.grab_focus
			return false
	edited_action.set(property_info.prop_name, sub_effect_payload)
	return true
