extends GameObject


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _can_actor_do_Push(actor):
	if check_adjacent(actor) and WRLD.is_tile_walkable(self.game_position  - (actor.game_position - self.game_position) ):
		return true
	return false
		
func _actor_do_Push(actor):
	self.game_position = self.game_position  - (actor.game_position - self.game_position)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
