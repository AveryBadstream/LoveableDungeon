extends GameAction


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.

func _init(actor).(actor):
	self.target_hints |= ACT.TargetHint.WholeCellMustSupport
	self.target_type = ACT.TargetType.TargetTile
	self.action_type = ACT.Type.Move
	self.target_area = ACT.TargetArea.TargetCell

func get_viable_targets():
	pass

func _on_phase_Can_Impossible(_1,_2,_3):
	self.action_state = ACT.ActionState.Failed
	return ACT.ActionResponse.Failed

func mark_pending():
	MSG.action_message("Move where?", self)

func finish():
	self.action_actor.game_position = self.action_targets[0].game_position
	self.action_state = ACT.ActionState.Complete
	EVNT.emit_signal("action_complete", self)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
