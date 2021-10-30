extends GameObject


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var opened = false
var isopen
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func _can_support_Move(action):
	return opened

func _can_support_Open(action):
	return !opened

func _can_support_Close(action):
	return opened
	
func _do_action_Open(action):
	opened = true
	frame = 1
	default_action = ACT.Type.Move
	is_walkable = true
	self.set_blocks_vision(false)
	return ACT.ActionResponse.Proceed

func _do_action_Close(action):
	opened = false
	frame = 0
	default_action = ACT.Type.Open
	is_walkable = false
	self.set_blocks_vision(true)
	return ACT.ActionResponse.Proceed
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
