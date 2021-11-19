extends GameAction


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(Script) var move_effect = preload("res://effects/Move.gd")
# Called when the node enters the scene tree for the first time.

func get_viable_targets():
	pass

func _on_phase_Can_Impossible(_1,_2,_3):
	self.action_state = ACT.ActionState.Failed
	return ACT.ActionResponse.Failed

func do():
	for target in self.action_targets:
		EFCT.queue_now(move_effect.new(self.action_actor, self.action_actor, self.action_targets[0].game_position))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
