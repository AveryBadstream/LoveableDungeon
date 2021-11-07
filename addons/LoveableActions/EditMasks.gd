tool
extends GridContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const action_scripts_path = "res://actions/action_scripts/"

const priority_item = preload("res://addons/LoveableActions/TargetPriorityItem.tscn")

onready var target_type_list = $TargetType/ScrollContainer/TargetTypeList
onready var target_hint_list = $TargetType/ScrollContainer2/TargetHintList
onready var cim_list = $CastCIM/CastCIMList
onready var tcim_list = $CastTCIM/CastTCIMList
onready var xcim_list = $CastXCIM/CastXCIMList

var hint_kvp = []
var target_kvp = []
var cim_kvp = []

var script_effect_settings = []

var edited_action

# Called when the node enters the scene tree for the first time.
func _ready():
	var i = 0
	for key in ACT.TargetHint.keys():
		var kvp = [key, ACT.TargetHint[key]]
		if i > 0:
			var new_checkbox := CheckButton.new()
			new_checkbox.show()
			new_checkbox.text = key
			target_hint_list.add_child(new_checkbox)
			new_checkbox.show()
		hint_kvp.append(kvp)
		i += 1
	i = 0
	for key in ACT.TargetType.keys():
		var kvp = [key, ACT.TargetType[key]]
		if i > 0:
			var new_checkbox := CheckButton.new()
			new_checkbox.show()
			new_checkbox.text = key
			target_type_list.add_child(new_checkbox)
			new_checkbox.show()
		target_kvp.append(kvp)
		i += 1
	for key in TIL.CellInteractions.keys():
		if TIL.CellInteractions[key] == 0:
			continue
		var kvp = [key, TIL.CellInteractions[key]]
		var new_checkbox := CheckButton.new()
		new_checkbox.text = key
		cim_list.add_child(new_checkbox)
		new_checkbox.show()
		var new_tcim_checkbox := CheckButton.new()
		new_tcim_checkbox.text = key
		tcim_list.add_child(new_tcim_checkbox)
		new_tcim_checkbox.show()
		var new_xcim_checkbox := CheckButton.new()
		new_xcim_checkbox.text = key
		xcim_list.add_child(new_xcim_checkbox)
		new_xcim_checkbox.show()
		cim_kvp.append(kvp)

func set_icon_list(editor_icons):
	pass

func change_edited_action(next_edited_action):
	edited_action = next_edited_action
