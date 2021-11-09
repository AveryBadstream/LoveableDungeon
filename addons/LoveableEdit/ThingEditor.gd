tool
extends TabContainer

var edited_object
var editor_icons
# Called when the node enters the scene tree for the first time.
onready var interaction_editor = $InteractionEditor
onready var actions_editor = $ActionEdit

func _ready():
	set_tab_title(0, "Interactions")
	set_tab_title(1, "Actions")
	if editor_icons and interaction_editor:
		interaction_editor.set_icon_list(editor_icons)
	if editor_icons and actions_editor:
		actions_editor.set_icon_list(editor_icons)


func focus_object(new_obj):
	if edited_object != new_obj:
		edited_object = new_obj
		interaction_editor.focus_object(new_obj)
		if new_obj is GameActor:
			set_tab_disabled(1, false)
			actions_editor.focus_object(new_obj)
		else:
			set_tab_disabled(1, true)
			actions_editor.focus_object(null)

func set_icon_list(icons):
	editor_icons = icons
	if interaction_editor:
		interaction_editor.set_icon_list(icons)
	if actions_editor:
		actions_editor.set_icon_list(icons)
