extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
signal update_object_vision_block(actor, old_pos, new_pos, should_block)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func subscribe(signal_name, target, target_method):
	connect(signal_name, target, target_method)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
