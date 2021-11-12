extends GameAI


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func should_choose():
	return true

func choose_action():
	pass

func run_ai():
	DBG.clear_highlight()
	#DBG.highlight_octant(attached_actor.game_position, WRLD.GameWorld.Player.game_position)
	DBG.highlight_fov(attached_actor.game_position)
	attached_actor.local_actions[ACT.Type.None][0].do_action([self])
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
