extends GameObject


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var opened = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _can_actor_do_Open(actor):
	if check_adjacent(actor):
		return !opened
	return false
		
	
func _can_actor_do_Close(actor):
	if check_adjacent(actor):
		return opened
	return false
	
func _actor_do_Open(actor):
	opened = true
	frame = 1
	default_action = ACT.Type.Move
	is_walkable = true
	self.set_blocks_vision(false)

func _actor_do_Close(actor):
	opened = false
	frame = 0
	default_action = ACT.Type.Open
	is_walkable = false
	self.set_blocks_vision(true)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
