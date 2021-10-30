extends GameAction


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _init(actor).(actor):
	self.target_type = ACT.TargetType.TargetObject
	self.action_type = ACT.Type.Close
	self.target_area = ACT.TargetArea.TargetSingle

func get_viable_targets():
	pass

func _on_phase_Can_Impossible(_1,_2,_3):
	self.action_state = ACT.ActionState.Failed
	return ACT.ActionResponse.Failed

func mark_pending():
	MSG.action_message("Close what?", self)

func impossible():
	MSG.action_message("You can't close that.", self)
	.impossible()

func finish():
	#Objects need to close themselves I suppose?
	self.action_state = ACT.ActionState.Complete
	EVNT.emit_signal("action_complete", self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
