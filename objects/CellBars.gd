extends GameObject


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var opened = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _can_support_Move(action):
	return opened

func _on_toggle(toggled_by):
	opened = !opened
	frame = int(opened)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
