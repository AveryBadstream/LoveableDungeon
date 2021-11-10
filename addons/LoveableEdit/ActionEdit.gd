tool
extends GridContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const actions_path = "res://actions/action_resources/"

onready var action_list = $"Available Action/Action List"
onready var apply_button = $ApplyContainer/ApplyButton

onready var default_type_option = $ApplyTo/DefaultApply/DefaultTypeOption
onready var default_script = $ApplyTo/DefaultApply/DefaultScript
onready var clear_default = $ApplyTo/DefaultApply/ClearDefaultButton

onready var assigned_actions = $ApplyTo/ActionList/VBoxContainer2/ActionsList
onready var remove_button = $ApplyTo/ActionList/VBoxContainer2/PanelContainer/HBoxContainer/RemoveButton
onready var clear_button = $ApplyTo/ActionList/VBoxContainer2/PanelContainer/HBoxContainer/ClearButton

onready var default_check = $ApplyTo/DefaultApply/UseDefaultButton
onready var actions_check = $ApplyTo/ActionList/VBoxContainer/ActionsButton

var apply_default = false
var edited_object
var action_scripts = []
var action_objects = []
var assigned_action_l = []
var act_kvp = []
var editor_icons
# Called when the node enters the scene tree for the first time.
func _ready():
	var action_script_dir = Directory.new()
	action_list.clear()
	if action_script_dir.open(actions_path) == OK:
		action_script_dir.list_dir_begin(true, true)
		var next_action_path = action_script_dir.get_next()
		var i = 0
		while next_action_path:
			print("Trying to load: "+next_action_path)
			if !action_script_dir.current_is_dir():
				var res_obj = ResourceLoader.load(actions_path+next_action_path)
				action_objects.append(res_obj)
				action_scripts.append(next_action_path)
				action_list.add_item(res_obj.action_name)
				action_list.set_item_metadata(i, actions_path + next_action_path)
			next_action_path = action_script_dir.get_next()
	else:
		print("For some fucking reason it failed...")
	default_type_option.clear()
	var i = 0
	for key in ACT.Type.keys():
		var kvp = [key, ACT.Type[key]]
		if i > 0:
			default_type_option.add_item(key, i)
		act_kvp.append(kvp)
		i += 1
	default_check.pressed = apply_default
	actions_check.pressed = !apply_default

func focus_object(new_obj):
	edited_object = new_obj
	if new_obj is GameActor:
		for action in new_obj.actions:
			var fname = action.action_name
			assigned_actions.add_item(fname)
			assigned_action_l.append(fname)
		update_default_display()

func set_icon_list(icons):
	editor_icons = icons
	apply_button.icon = editor_icons["arrowright"]
	remove_button.icon = editor_icons["remove"]
	clear_default.icon = editor_icons["remove"]
	clear_button.icon = editor_icons["reload"]

func _on_ActionSearch_text_changed(new_text: String):
	action_list.unselect_all()
	if new_text == "":
		return
	for i in range(action_scripts.size()):
		if action_scripts[i].begins_with(new_text):
			action_list.select(i)
			action_list.ensure_current_is_visible()


func update_apply_buttons():
	actions_check.pressed = !apply_default
	default_check.pressed = apply_default
	if apply_default:
		clear_button.disabled = true
		remove_button.disabled = true
		default_type_option.disabled = false
		for i in range(assigned_actions.get_item_count()):
			assigned_actions.set_item_disabled(i)
		action_list.unselect_all()
		action_list.select_mode = ItemList.SELECT_SINGLE
	else:
		clear_button.disabled = false
		remove_button.disabled = false
		default_type_option.disabled = true
		for i in range(assigned_actions.get_item_count()):
			assigned_actions.set_item_disabled(i, false)
		action_list.select_mode = ItemList.SELECT_MULTI


func _on_ActionsButton_toggled(button_pressed):
	apply_default = !button_pressed
	update_apply_buttons()


func _on_UseDefaultButton_toggled(button_pressed):
	apply_default = button_pressed
	update_apply_buttons()

func update_default_display():
	var default_key = default_type_option.get_selected_id()
	if edited_object.default_actions.has(act_kvp[default_key][1]):
		default_script.text = edited_object.default_actions[act_kvp[default_key][1]].action_name
	else:
		default_script.text = ""

func _on_ApplyButton_pressed():
	if apply_default:
		var default_key = default_type_option.get_selected_id()
		if default_key != 0:
			var new_action = action_objects[action_list.get_selected_items()[0]].duplicate()
			var new_dict = edited_object.default_actions
			new_dict[act_kvp[default_key][1]] = new_action
			edited_object.default_actions = new_dict
			new_dict[act_kvp[default_key][1]].resource_local_to_scene = true
			new_action.resource_local_to_scene = true
			edited_object.property_list_changed_notify()
			update_default_display()
	else:
		if not edited_object.actions:
			edited_object.actions = []
		var to_add_actions = []
		for i in action_list.get_selected_items():
			var new_action:Resource = action_objects[i].duplicate()
			to_add_actions.append(new_action)
			new_action.resource_local_to_scene = true
		edited_object.actions.append_array(to_add_actions)
		edited_object.property_list_changed_notify()


func _on_DefaultTypeOption_item_selected(index):
	update_default_display() # Replace with function body.


func _on_ClearDefaultButton_pressed():
	var default_key = default_type_option.get_selected_id()
	edited_object.default_actions.erase(act_kvp[default_key][1])
	edited_object.property_list_changed_notify()
	update_default_display()
