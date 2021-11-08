tool
extends VBoxContainer

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var act_kvp = []
var hint_kvp = []
var action_scripts = []
var action_script_objects = []
var edited_action
var is_saved = false

onready var tabs = $ActionManagerTabs
onready var edit_tab = $ActionManagerTabs/EditAction
onready var list_tab = $ActionManagerTabs/ActionsList
onready var mask_tab = $ActionManagerTabs/EditMasks
onready var effects_tab = $ActionManagerTabs/Effects

onready var new_button = $OptionsMenubar/NewButton
onready var save_button = $OptionsMenubar/SaveButton

const game_action_script = GameAction

const action_scripts_path = "res://actions/action_scripts/"

var editor_icons = {}

# Called when the node enters the scene tree for the first time.
func _ready():
	tabs.set_tab_title(0, "All Actions")
	tabs.set_tab_title(1, "Basics")
	tabs.set_tab_title(2, "Masks")
	tabs.set_tab_title(3, "Effects")
	tabs.set_tab_disabled(1, true)
	tabs.set_tab_disabled(2, true)
	tabs.set_tab_disabled(3, true)

func new_action():
	edited_action = GameAction.new()
	edit_tab.change_edited_action(edited_action)
	mask_tab.change_edited_action(edited_action)
	effects_tab.change_edited_action(edited_action)
	tabs.set_tab_disabled(1, false)
	tabs.set_tab_disabled(2, false)
	tabs.set_tab_disabled(3, false)
	tabs.set_current_tab(1)

func set_icon_list(editor_icons):
	list_tab.set_icon_list(editor_icons)
	edit_tab.set_icon_list(editor_icons)
	mask_tab.set_icon_list(editor_icons)
	effects_tab.set_icon_list(editor_icons)
	new_button.icon = editor_icons.new
	save_button.icon = editor_icons.save


func _on_edit_new_resource():
	new_action() 


func _on_save_resource():
	if not edit_tab.set_tab_data():
		tabs.set_current_tab(1)
	elif not mask_tab.set_tab_data():
		tabs.set_current_tab(2)
	elif not effects_tab.set_tab_data():
		tabs.set_current_tab(3)
	else:
		$FileDialog.popup_centered()



func _on_FileDialog_file_selected(path):
	ResourceSaver.save(path, edited_action) # Replace with function body.
