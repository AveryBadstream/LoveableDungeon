tool
extends VBoxContainer

const effect_entry = preload("res://addons/LoveableActions/EffectEntry.tscn")
onready var effects_list = $Scroll/EffectsList

var effect_entries = []
var editor_icons
var edited_action
const game_action_path = "res://actions/GameAction.gd"
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func change_edited_action(next_edited_action):
	edited_action = next_edited_action
	if edited_action == null:
		clear_effect_entries()

func clear_effect_entries():
	for child in effects_list.get_children():
		child.clear_effect_entries()
		effects_list.remove_child(child)
		child.queue_free()

func _on_update_effect_settings(effect_settings, next_edited_action):
	edited_action = next_edited_action
	print("New effect settings:" + str(effect_settings))
	clear_effect_entries()
	var first = true
	var i = 0
	for setting in effect_settings:
		print("Individual setting: " + str(setting))
		if i > 50:
			break
		print(str(i))
		if first:
			first = false
		else:
			effects_list.add_child(HSeparator.new())
			first = false
		var new_entry = effect_entry.instance()
		effects_list.add_child(new_entry)
		new_entry.set_icon_list(editor_icons)
		new_entry.process_property(setting)
		new_entry.change_edited_action(edited_action)
		effect_entries.append(new_entry)
		break
		i += 1
	
func set_icon_list(editor_icons_in):
	editor_icons = editor_icons_in

func set_tab_data():
	for child in effects_list.get_children():
		if not child.set_effect_data():
			return false
	return true
