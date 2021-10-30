extends GameAI

export(float, 0.0, 1.0) var sleep_chance = 0.0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var move_count = 0
var movement_action = null

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _init(actor).(actor):
	pass

func should_choose():
	if movement_action:
		return true
	else:
		for action in attached_actor.local_actions[ACT.Type.Move]:
			movement_action = action
			return true
	return false

func run_ai():
	var possible_targets = WRLD.get_action_targets_area(movement_action, attached_actor.game_position, 1)
	if possible_targets.size() == 0:
		return
	var final_target = [possible_targets[WRLD.rng.randi() % possible_targets.size()]]
	movement_action.do_action(final_target)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
