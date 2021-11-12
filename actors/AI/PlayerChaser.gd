extends GameAI

class_name PlayerChaser

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var to_player_path
var last_player_pos
var current_path_i

var next_action
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func should_choose():
	if WRLD.can_see_player(self.attached_actor):
		to_player_path = WRLD.path_to_player(attached_actor)
		last_player_pos = WRLD.get_player_position()
		current_path_i = 0
		return true
	elif attached_actor.game_position != last_player_pos and (to_player_path and current_path_i < to_player_path.size() - 1):
		return true
	else:
		return false

func choose_action():
	if attached_actor.local_default_actions.has(ACT.Type.Attack):
		var attack:GameAction = attached_actor.local_default_actions[ACT.Type.Attack]
		if attack.test_action_at(to_player_path[current_path_i+1]) and WRLD.get_player_position() == to_player_path[current_path_i+1]:
			next_action = attack
			return
	if attached_actor.local_default_actions.has(ACT.Type.Move):
		var move:GameAction = attached_actor.local_default_actions[ACT.Type.Move]
		if move.test_action_at(to_player_path[current_path_i+1]):
			next_action = move
	else:
		to_player_path = null
		next_action = null

func run_ai():
	current_path_i += 1
	if next_action:
		next_action.do_action_at(to_player_path[current_path_i])
	else:
		to_player_path = null
		EVNT.emit_signal("turn_over")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
