tool
extends GridContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const actions_path = "res://actions/action_scripts/"

onready var action_list = $"Available Action/Action List"

var edited_object
var action_scripts = []
var action_objects = []
# Called when the node enters the scene tree for the first time.
func _ready():
	var action_script_dir = Directory.new()
	if action_script_dir.open(actions_path) == OK:
		action_script_dir.list_dir_begin(true, true)
		var next_action_path = action_script_dir.get_next()
		var i = 0
		while next_action_path:
			if !action_script_dir.current_is_dir():
				var res_obj = load(actions_path+next_action_path)
				action_scripts.append(next_action_path)
				action_list.add_item(next_action_path.get_file())
				action_list.set_item_metadata(i, actions_path + next_action_path)
			next_action_path = action_script_dir.get_next()
	else:
		print("For some fucking reason it failed...")

func update_action_list():
	for item in edited_object.test_res_array:
		var scripts_i = action_scripts.find(item.get_script().filename)
		if scripts_i >= 0:
			action_list.select(action_objects[scripts_i].new())

func save_action_items():
	var new_action_list = []
	for i in range(action_scripts.size()):
		if action_list.is_selected(i):
			new_action_list.append()
#	var path = action_list.get_item_metadata(al_id)
#	var found = false
#	for item in edited_object.test_res_away:
#		if item.get_path() == path:
#			found = true
#	if not found:
#		edited_object.test_res_array.append()

func focus_object(new_obj):
	edited_object = new_obj
	if new_obj is GameActor:
		update_action_list()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
