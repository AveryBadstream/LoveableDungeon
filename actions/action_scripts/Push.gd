extends GameAction


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(Script) var push_effect = preload("res://effects/Push.gd")
export(int) var push_effect_magnitude = 1

func get_viable_targets():
	pass

func _on_phase_Can_Impossible(_1,_2,_3):
	self.action_state = ACT.ActionState.Failed
	return ACT.ActionResponse.Failed

func do():
	for target in self.action_targets:
		EFCT.queue_now(push_effect.new(self.action_actor, self.action_targets[0], 1))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
