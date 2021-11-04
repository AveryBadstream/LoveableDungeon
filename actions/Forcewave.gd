extends GameAction

var push_effect = preload("res://effects/Push.gd")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func _init(actor).(actor):
	self.target_type = ACT.TargetType.TargetObject | ACT.TargetType.TargetActor | ACT.TargetType.TargetItem
	self.action_type = ACT.Type.Push
	self.target_area = ACT.TargetArea.TargetCone
	self.target_priority = [ACT.TargetType.TargetActor, ACT.TargetType.TargetObject, ACT.TargetType.TargetItem, ACT.TargetType.TargetTile]

func get_viable_targets():
	pass

func _on_phase_Can_Impossible(_1,_2,_3):
	self.action_state = ACT.ActionState.Failed
	return ACT.ActionResponse.Failed

func mark_pending():
	MSG.action_message("FUS", self)
	EVNT.emit_signal("hint_area_cone", action_actor.game_position, 5, deg2rad(90))

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
	self.publish_effect(push_effect.new(self, self.action_actor, self.action_targets[0], 3))

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
