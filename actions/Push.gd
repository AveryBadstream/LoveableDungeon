extends GameAction


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _init(actor).(actor):
	self.target_type = ACT.TargetType.TargetObject | ACT.TargetType.TargetActor
	self.action_type = ACT.Type.Push
	self.target_area = ACT.TargetArea.TargetSingle
	self.target_priority = [ACT.TargetType.TargetActor, ACT.TargetType.TargetObject, ACT.TargetType.TargetItem, ACT.TargetType.TargetTile]

func get_viable_targets():
	pass

func _on_phase_Can_Impossible(_1,_2,_3):
	self.action_state = ACT.ActionState.Failed
	return ACT.ActionResponse.Failed

func mark_pending():
	MSG.action_message("Push what?", self)

func impossible():
	MSG.action_message("You can't push that.", self)
	.impossible()

func do_action(targets):
	assert(targets.size() == 1)
	if WRLD.is_tile_walkable(targets[0].game_position  - (self.action_actor.game_position  - targets[0].game_position).normalized() ):
		.do_action(targets)
	else:
		impossible()

func finish():
	#Maybe this is a case to add the event structures I want?
	action_targets[0].game_position = action_targets[0].game_position  - (self.action_actor.game_position  - action_targets[0].game_position).normalized().round() 
	self.action_state = ACT.ActionState.Complete
	EVNT.emit_signal("action_complete", self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
