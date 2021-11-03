extends Reference

class_name GameAction
# Declare member variables here. Examples:
# var a = 2
const is_action = false
# var b = "text"
var action_actor
var action_type = ACT.Type.None
var action_targets
var target_hints = ACT.TargetHint.None
var action_range = 1.5
var action_area = 0
var action_state = ACT.ActionState.Ready
var target_type = ACT.TargetType.TargetNone
var target_area = ACT.TargetArea.TargetSingle
var target_priority = [ACT.TargetType.TargetTile, ACT.TargetType.TargetObject, ACT.TargetType.TargetItem, ACT.TargetType.TargetActor]
var running_effects = []
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _init(actor):
	self.action_actor = actor
	
func set_target_types(target_types: Array) -> void:
	for individual_target_type in target_types:
		self.target_type |= individual_target_type

func get_viable_targets():
	pass

func complete():
	pass

func get_origin_cell():
	return self.action_actor.game_position

func do_action_at(target_cell):
	var targets = WRLD.get_action_targets_cell(self, target_cell)
	if targets.size() == 0:
		self.impossible()
		return false
	if target_area == ACT.TargetArea.TargetSingle:
		if targets.size() == 1:
			self.do_action(targets)
			return
		var lowest_priority = target_priority.size()
		var actual_target = null
		for target in targets:
			var next_priority = target_priority.find(target.thing_type)
			if next_priority < lowest_priority and next_priority != -1:
				lowest_priority = next_priority
				actual_target = target
		self.do_action([actual_target])
		return
	elif target_area == ACT.TargetArea.TargetCell:
		self.do_action(targets)
		return true
	self.impossible()
	return false

func test_action_at(at_cell):
	if action_actor.game_position.distance_to(at_cell) > action_range:
		return false
	var targets = WRLD.get_action_targets_cell(self, at_cell)
	if targets.size() == 0:
		return false
	return true

func publish_effect(effect):
	self.running_effects.append(effect)
	EVNT.publish_effect(effect)

func effect_done(effect):
	self.running_effects.erase(effect)
	if running_effects.size() == 0:
		self.action_targets = []
		self.action_state = ACT.ActionState.Complete
		EVNT.emit_signal("action_complete", self)

func get_action_targets():
	return WRLD.get_action_targets_area(self, self.get_origin_cell(), self.action_range)

func process_action_response(action_phase, action_response, actor):
	if self.has_method("_on_phase_"+ACT.ActionPhase.keys()[action_phase]+"_"+ACT.ActionResponse.keys()[action_response]):
		return self.call("_on_phase_"+ACT.ActionPhase.keys()[action_phase]+"_"+ACT.ActionResponse.keys()[action_response], action_phase, action_response, actor)
	elif self.has_method("_on_phase_any_"+ACT.ActionResponse.keys()[action_response]):
		return self.call("_on_phase_any_"+ACT.ActionResponse.keys()[action_response], action_phase, action_response, actor)
	elif self.has_method("_on_phase_"+ACT.ActionPhase.keys()[action_phase]+"_"+"any"):
		return self.call("_on_phase_"+ACT.ActionPhase.keys()[action_phase]+"_"+"any", action_phase, action_response, actor)
	else:
		return ACT.ActionResponse.Proceed

func fail():
	self.action_state = ACT.ActionState.Failed

func mark_pending():
	pass
	
func impossible():
	self.action_state = ACT.ActionState.Impossible
	EVNT.emit_signal("action_impossible", self)

func finish():
	self.action_targets = []
	self.action_state = ACT.ActionState.Complete
	EVNT.emit_signal("action_complete", self)

func do_action(targets):
	self.action_targets = targets
	self.action_state = ACT.ActionState.Acting
	EVNT.publish_action(self)

func effect_finished(effect):
	self.action_state = ACT.ActionState.Complete
	EVNT.emit_signal("action_complete", self)
