extends GameAction


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
export(Script) var push_effect = preload("res://effects/Push.gd")
export(int) var push_effect_magnitude = 1

func set_owned_by(actor):
	self.target_type = ACT.TargetType.TargetObject | ACT.TargetType.TargetActor | ACT.TargetType.TargetItem
	self.action_type = ACT.Type.Push
	self.target_area = ACT.TargetArea.TargetSingle
	self.target_priority = [ACT.TargetType.TargetActor, ACT.TargetType.TargetObject, ACT.TargetType.TargetItem, ACT.TargetType.TargetTile]
	.set_owned_by(actor)

func get_viable_targets():
	pass

func _on_phase_Can_Impossible(_1,_2,_3):
	self.action_state = ACT.ActionState.Failed
	return ACT.ActionResponse.Failed

func mark_pending():
	MSG.action_message("Push what?", self)
	.mark_pending()

func impossible():
	MSG.action_message("You can't push that.", self)
	.impossible()

func do():
	EFCT.queue_now(push_effect.new(self.action_actor, self.action_targets[0], 1))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
