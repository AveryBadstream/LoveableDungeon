extends GameAI

class_name PlayerControlled
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func should_choose():
	return true

func choose_action():
	pass

func run_ai():
	EVNT.emit_signal("player_active", attached_actor)



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
