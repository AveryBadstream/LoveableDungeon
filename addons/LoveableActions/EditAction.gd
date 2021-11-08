tool
extends VBoxContainer

signal update_effect_settings(effect_settings)
const action_scripts_path = "res://actions/action_scripts/"

const priority_item = preload("res://addons/LoveableActions/TargetPriorityItem.tscn")

onready var type_options = $EditorWindow/ActionSettings/ActionSettingsGrid/Fields/TypeOptions
onready var script_list = $EditorWindow/ActionScripts/ScriptsList
onready var script_reload_button = $EditorWindow/ActionScripts/ScriptsTitle/ReloadScriptsButton
onready var name_entry = $EditorWindow/ActionSettings/ActionSettingsGrid/Fields/NameEntry
onready var area_options = $EditorWindow/ActionSettings/ActionSettingsGrid/Fields/AreaOptions
onready var range_box = $EditorWindow/ActionSettings/ActionSettingsGrid/Fields/TargetRangeBox
onready var area_box = $EditorWindow/ActionSettings/ActionSettingsGrid/Fields/TargetAreaBox
onready var priority_list = $EditorWindow/ActionSettings/ScrollContainer/TargetPrioritiesList

var act_kvp = []
var hint_kvp = []
var target_kvp = []
var action_scripts = []
var area_kvp = []

var script_effect_settings = []
var script_effect_names = []
var unassigned_effect_settings = []

var edited_action

# Called when the node enters the scene tree for the first time.
func _ready():
	type_options.clear()
	for key in ACT.Type.keys():
		act_kvp.append([key, ACT.Type[key]])
		type_options.add_item(key)
	var i = 0

	area_options.clear()
	for key in ACT.TargetArea.keys():
		area_kvp.append([key, ACT.TargetArea[key]])
		area_options.add_item(key)
	reload_action_scripts()
	i = 0
	for key in ACT.TargetType.keys():
		var kvp = [key, ACT.TargetType[key]]
		target_kvp.append(kvp)
		i += 1
	for j in range(1, target_kvp.size()):
		var new_priority = priority_item.instance()
		priority_list.add_child(new_priority)
		new_priority.setup(target_kvp[j][0], target_kvp[j][1])
		new_priority.connect("move_up", self, "move_priority_up")
		new_priority.connect("move_down", self, "move_priority_down")
	update_list_positions()

func move_priority_up(priority_entry):
	priority_list.move_child(priority_entry, priority_entry.list_position - 2)
	update_list_positions()

func update_list_positions():
	var i = 1
	var max_i = priority_list.get_child_count()
	for child in priority_list.get_children():
		child.set_list_position(i, max_i)
		i += 1

func move_priority_down(priority_entry):
	priority_list.move_child(priority_entry, priority_entry.list_position)
	update_list_positions()

func reload_action_scripts():
	var action_script_dir = Directory.new()
	script_list.clear()
	if action_script_dir.open(action_scripts_path) == OK:
		action_script_dir.list_dir_begin(true, true)
		var next_script_file = action_script_dir.get_next()
		var i = 0
		while next_script_file:
			if !action_script_dir.current_is_dir():
				action_scripts.append(action_scripts_path + next_script_file)
				script_list.add_item(next_script_file.get_file())
				script_list.set_item_metadata(i, action_scripts_path + next_script_file)
			next_script_file = action_script_dir.get_next()

func set_icon_list(editor_icons):
	script_reload_button.icon = editor_icons.reload
	for child in priority_list.get_children():
		child.set_icon_list(editor_icons)

func change_edited_action(next_edited_action):
	edited_action = next_edited_action

func _on_ScriptsList_item_selected(index):
	script_effect_names = []
	script_effect_settings = []
	unassigned_effect_settings = []
	edited_action.script = load(action_scripts[index])
	for prop in edited_action.get_property_list():
		print(str(prop))
		if "_effect" in prop.name:
			var prop_parts = prop.name.split("_", true, 2)
			if prop_parts.size() == 2:
				script_effect_names.append(prop_parts[1])
				script_effect_settings.append({"name": prop_parts[1], "script": null, "prop_name": prop.name})
			elif prop_parts.size() == 3:
				unassigned_effect_settings.append([prop_parts[1], prop_parts[2], prop])
	for prop_info in unassigned_effect_settings:
		var names_i = script_effect_names.find(prop_info[0])
		if names_i != -1:
			var script_effect_setting = script_effect_settings[names_i]
			if not script_effect_setting.keys().has("sub_properties"):
				script_effect_setting["sub_properties"] = []
			script_effect_setting["sub_properties"].append({ \
								"name": prop_info[1],
								"prop_name": prop_info[2].name,
								"type": prop_info[2].type,
								"value": null
							})
	emit_signal("update_effect_settings", script_effect_settings)
