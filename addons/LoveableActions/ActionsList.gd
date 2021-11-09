tool
extends VBoxContainer

signal load_new_resource(action_resource)

const action_resource_path = "res://actions/action_resources/"

onready var action_list = $ActionsItemList

var action_resources = []

# Called when the node enters the scene tree for the first time.
func _ready():
	reload_action_resources() # Replace with function body.

func reload_action_resources():
	var action_resource_dir = Directory.new()
	action_list.clear()
	if action_resource_dir.open(action_resource_path) == OK:
		action_resource_dir.list_dir_begin(true, true)
		var next_script_file = action_resource_dir.get_next()
		var i = 0
		while next_script_file:
			if !action_resource_dir.current_is_dir():
				action_resources.append(action_resource_path + next_script_file)
				action_list.add_item(next_script_file.get_file())
				action_list.set_item_metadata(i, action_resource_path + next_script_file)
			next_script_file = action_resource_dir.get_next()

func set_icon_list(editor_icons):
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_item_selected(index):
	emit_signal("load_new_resource", load(action_resources[index])) # Replace with function body.
