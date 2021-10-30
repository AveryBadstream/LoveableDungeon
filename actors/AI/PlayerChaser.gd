extends GameAI


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _init(actor).(actor):
	pass

func should_choose():
	if WRLD.can_see_player(self.attached_actor):
		print("I See You")
	else:
		print("WHERE DID YOU GO?")
	return false
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
