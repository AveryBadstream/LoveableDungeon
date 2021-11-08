tool
extends VBoxContainer

const effect_path = "res://effects/"

const sub_effect_entry = preload("res://addons/LoveableActions/SubEffectEntry.tscn")

onready var open_dialog = $FileDialog
onready var effect_name = $EffectBox/EffectName
onready var effect_path_line = $EffectBox/EffectPath
onready var load_button = $EffectBox/Load

var property_info
var sub_props = []
var edited_action

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func set_icon_list(editor_icons):
	load_button.icon = editor_icons.load

func _on_Load_pressed():
	open_dialog.popup()

func process_property(prop):
	property_info = prop
	effect_name.text = prop.name
	sub_props = []
	if prop.keys().has("sub_properties"):
		for sr in prop.sub_properties:
			var new_sr_entry = sub_effect_entry.instance()
			add_child(new_sr_entry)
			new_sr_entry.process_property(sr)
			sub_props.append(new_sr_entry)

func _on_FileDialog_file_selected(path):
	effect_path_line.text = path

func change_edited_action(next_edited_action):
	edited_action = next_edited_action
	var i = 0
	print(str(sub_props.size()))
	for child in sub_props:
		if i > 50:
			break
		print("Changing edited action on: " + str(child.property_info.name))
		child.change_edited_action(next_edited_action)
		i += 1
		break

func set_effect_data():
	var effect_script
	if effect_path_line.text == "":
		effect_path_line.grab_focus()
		return false
	effect_script = load(effect_path_line.text)
	if not effect_script is Script:
		effect_path_line.grab_focus()
		return false
	edited_action.set(property_info.prop_name, effect_script)
	for child in sub_props:
		if not child.set_sub_effect_data():
			return false
	return true
	 
