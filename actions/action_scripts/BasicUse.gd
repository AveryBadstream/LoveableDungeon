extends GameAction


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var use_effect = preload("res://effects/Use.gd")

func _init(actor).(actor):
	self.target_type = ACT.TargetType.TargetObject | ACT.TargetType.TargetActor
	self.action_type = ACT.Type.Use
	self.target_area = ACT.TargetArea.TargetSingle
	self.target_priority = [ACT.TargetType.TargetObject, ACT.TargetType.TargetActor, ACT.TargetType.TargetItem, ACT.TargetType.TargetTile]

func get_viable_targets():
	pass

func _on_phase_Can_Impossible(_1,_2,_3):
	self.action_state = ACT.ActionState.Failed
	return ACT.ActionResponse.Failed

func mark_pending():
	MSG.action_message("Use what?", self)
	.mark_pending()

func impossible():
	MSG.action_message("You can't use that.", self)
	.impossible()

func do():
	EFCT.queue_now(use_effect.new(self.action_actor, self.action_targets[0]))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass