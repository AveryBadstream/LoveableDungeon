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
			kvp.append(new_checkbox)
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
			kvp.append(new_checkbox)
		target_kvp.append(kvp)
		i += 1
	for key in TIL.CellInteractions.keys():
		if TIL.CellInteractions[key] == 0:
			continue
		var kvp = [key, TIL.CellInteractions[key]]
		var new_checkbox := CheckButton.new()
		new_checkbox.text = key
		cim_list.add_child(new_checkbox)
		kvp.append(new_checkbox)
		new_checkbox.show()
		var new_tcim_checkbox := CheckButton.new()
		new_tcim_checkbox.text = key
		tcim_list.add_child(new_tcim_checkbox)
		kvp.append(new_tcim_checkbox)
		new_tcim_checkbox.show()
		var new_xcim_checkbox := CheckButton.new()
		new_xcim_checkbox.text = key
		xcim_list.add_child(new_xcim_checkbox)
		kvp.append(new_xcim_checkbox)
		new_xcim_checkbox.show()
		cim_kvp.append(kvp)

func set_icon_list(editor_icons):
	pass

func change_edited_action(next_edited_action):
	edited_action = next_edited_action
	print(str(hint_kvp))
	for kvp in hint_kvp:
		if kvp.size() >2:
			kvp[2].set_pressed( edited_action.target_hints & kvp[1] > 0)
	for kvp in cim_kvp:
		if kvp.size() >2:
			kvp[2].set_pressed( edited_action.c_cim & kvp[1] > 0)
			kvp[3].set_pressed( edited_action.target_cim & kvp[1] > 0)
			kvp[4].set_pressed( edited_action.x_cim & kvp[1] > 0)
	for kvp in target_kvp:
		if kvp.size() >2:
			kvp[2].set_pressed( edited_action.target_type & kvp[1] > 0)

func set_tab_data():
	var hint_mask = 0
	for i in range(1, hint_kvp.size()):
		if hint_kvp[i][2].pressed:
			hint_mask |= hint_kvp[i][1]
	edited_action.target_hints = hint_mask
	var type_mask = 0
	for i in range(1, target_kvp.size()):
		if target_kvp[i][2].pressed:
			type_mask |= target_kvp[i][1]
	edited_action.target_type = type_mask
	var cim = 0
	var tcim = 0
	var xcim = 0
	for i in range(1, cim_kvp.size()):
		if cim_kvp[i][2].pressed:
			cim |= cim_kvp[i][1]
		if cim_kvp[i][3].pressed:
			tcim |= cim_kvp[i][1]
		if cim_kvp[i][4].pressed:
			xcim |= cim_kvp[i][1]
	edited_action.c_cim = cim
	edited_action.target_cim = tcim
	edited_action.x_cim = xcim
	return true
