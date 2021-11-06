extends GameObject


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var toggle_effect = preload("res://effects/Toggle.gd")
# Called when the node enters the scene tree for the first time.
var pulled = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func _do_action_Use(action):
	var new_toggle = toggle_effect.new(self, connects_to)
	EFCT.queue_delayed(new_toggle)
	return ACT.ActionResponse.Proceed

func effect_done(effect):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
