tool
extends VBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal move_up(element)
signal move_down(element)

onready var up_button = $HBoxContainer/MoveArrows/UpButton
onready var down_button = $HBoxContainer/MoveArrows/DownButton
onready var name_label = $HBoxContainer/TargetTypeName
onready var top_sep = $TopSep
onready var bot_sep = $BotSep

var target_key
var target_value

var list_position

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func setup(target_type_key, target_type_value):
	name_label.text = target_type_key
	target_key = target_type_key
	target_value = target_type_value


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func set_icon_list(editor_icons):
	up_button.icon = editor_icons.arrowup
	down_button.icon = editor_icons.arrowdown

func set_list_position(list_pos, max_pos):
	list_position = list_pos
	if list_pos == 1:
		up_button.disabled = true
		top_sep.hide()
	else:
		up_button.disabled = false
		top_sep.show()
	if list_pos == max_pos:
		down_button.disabled = true
		bot_sep.show()
	else:
		down_button.disabled = false
		bot_sep.hide()

func _on_UpButton_pressed():
	emit_signal("move_up", self)


func _on_DownButton_pressed():
	emit_signal("move_down", self)
