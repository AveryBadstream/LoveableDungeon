extends Sprite


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var delta_t = 0
export var playback_speed = 0.1
export var last_frame = 0
# Called when the node enters the scene tree for the first time.
func _ready(): # Replace with function body.
	pass

func _process(delta):
	delta_t += delta
	if delta_t >= playback_speed:
		if frame == last_frame:
			EVNT.emit_signal("FX_done", self)
		else:
			frame += 1
			delta_t = 0
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
