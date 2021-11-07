tool
extends EditorPlugin


const ActionManager =  preload("res://addons/LoveableActions/ActionManager.tscn")

var action_manager

var editor_icons = {}

func _enter_tree():
	var gui = get_editor_interface().get_base_control()
	editor_icons["reload"] = gui.get_icon("Reload", "EditorIcons")
	editor_icons["new"] = gui.get_icon("New", "EditorIcons")
	editor_icons["arrowup"] = gui.get_icon("ArrowUp", "EditorIcons")
	editor_icons["arrowdown"] = gui.get_icon("ArrowDown", "EditorIcons")
	action_manager = ActionManager.instance()
	get_editor_interface().get_editor_viewport().add_child(action_manager)
	action_manager.set_icon_list(editor_icons)
	action_manager.hide()

func has_main_screen():
	return true
	
func make_visible(visible):
	if action_manager:
		action_manager.visible = visible

func _exit_tree():
	if action_manager:
		action_manager.queue_free()

func get_plugin_name():
	return "Loveable Actions"

func get_plugin_icon():
	# Must return some kind of Texture for the icon.
	return get_editor_interface().get_base_control().get_icon("Node", "EditorIcons")
