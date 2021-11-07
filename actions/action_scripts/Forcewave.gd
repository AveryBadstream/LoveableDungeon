extends GameAction

var push_effect = preload("res://effects/Push.gd")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func set_owned_by(actor):
	self.target_type = ACT.TargetType.TargetObject | ACT.TargetType.TargetActor | ACT.TargetType.TargetItem
	self.action_type = ACT.Type.Push
	self.target_area = ACT.TargetArea.TargetCone
	self.target_priority = [ACT.TargetType.TargetActor, ACT.TargetType.TargetObject, ACT.TargetType.TargetItem, ACT.TargetType.TargetTile]
	self.action_range = 5
	self.action_area = deg2rad(60)
	.set_owned_by(actor)

func get_viable_targets():
	pass

func mark_pending():
	MSG.action_message("FUS", self)
	.mark_pending()

func impossible():
	MSG.action_message("You can't fus there.", self)
	.impossible()

func do():
	for target in self.action_targets:
		EFCT.queue_now(push_effect.new(action_actor, target, 5))
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
