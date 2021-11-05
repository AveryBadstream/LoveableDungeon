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
	self.action_range = 5
	self.action_area = deg2rad(60)

func get_viable_targets():
	pass

func mark_pending():
	MSG.action_message("FUS", self)
	EVNT.emit_signal("hint_area_cone", action_actor.game_position, action_range, action_area)

func impossible():
	MSG.action_message("You can't fus there.", self)
	.impossible()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
