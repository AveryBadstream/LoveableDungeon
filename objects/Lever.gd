extends GameObject


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
var pulled = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _do_action_Use(action):
	emit_signal("toggle", self)
	pulled = !pulled
	frame = int(pulled)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
