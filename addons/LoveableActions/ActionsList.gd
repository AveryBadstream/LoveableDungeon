tool
extends VBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

signal edit_new_resource()

onready var new_button_al = $ListOptions/NewButton

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.



func set_icon_list(editor_icons):
	new_button_al.icon = editor_icons.new
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_NewButton_pressed():
	emit_signal("edit_new_resource") # Replace with function body.
