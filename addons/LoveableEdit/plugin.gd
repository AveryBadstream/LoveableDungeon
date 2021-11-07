tool
extends EditorPlugin

const ThingEditor = preload("res://addons/LoveableEdit/ThingEditor.tscn")

var thing_editor
var bottom_button
var editor_selection

var focused_object

var action_manager

func _enter_tree():
	editor_selection = get_editor_interface().get_selection()
	editor_selection.connect("selection_changed", self, "_on_EditorSelection_selection_changed")
	thing_editor = ThingEditor.instance()

func handles(object):
	if object is GameObject:
		return true
	return false

func edit(object):
	set_focused_object(object)

func show_thing_dock(object):
	bottom_button = add_control_to_bottom_panel(thing_editor, "Edit Thing")
	bottom_button.connect("pressed", self, "_on_edit_thing_pressed")

func hide_thing_dock():
	remove_control_from_bottom_panel(thing_editor)

func _on_edit_thing_pressed():
	thing_editor.show()

func show_game_object_editor():
	if focused_object and thing_editor:
		if not thing_editor.is_inside_tree():
			add_control_to_bottom_panel(thing_editor, "Thing Editor")
		make_bottom_panel_item_visible(thing_editor)

func hide_game_object_editor():
	if thing_editor.is_inside_tree():
		remove_control_from_bottom_panel(thing_editor)
	
func _on_EditorSelection_selection_changed():
	var selected_nodes = editor_selection.get_selected_nodes()
	if selected_nodes.size() == 1:
		var selected_node = selected_nodes[0]
		if selected_node is GameObject:
			set_focused_object(selected_node)
			return
	set_focused_object(null)

func has_main_screen():
	return true

func get_plugin_name():
	return "LoveableEdit"

func _on_focused_object_changed(new_obj):
	if new_obj is GameObject:
		# Must be shown first, otherwise StateMachineEditor can't execute ui action as it is not added to scene tree
		show_game_object_editor()
		thing_editor.focus_object(new_obj)
#		var state_machine
#		if focused_object is StateMachinePlayer:
#			if focused_object.get_class() == "ScriptEditorDebuggerInspectedObject":
#				state_machine = focused_object.get("Members/state_machine")
#			else:
#				state_machine = focused_object.state_machine
#			state_machine_editor.state_machine_player = focused_object
#		elif focused_object is StateMachine:
#			state_machine = focused_object
#			state_machine_editor.state_machine_player = null
#		state_machine_editor.state_machine = state_machine
	else:
		hide_game_object_editor()

func set_focused_object(obj):
	if focused_object != obj:
		focused_object = obj
		_on_focused_object_changed(obj)

func _exit_tree():
#	remove_inspector_plugin(GameObjectEditor)
	if thing_editor:
		thing_editor.queue_free()
