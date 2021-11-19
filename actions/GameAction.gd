extends Resource

class_name GameAction
# Declare member variables here. Examples:
# var a = 2
const is_action = false
# var b = "text"
export(Resource) var action_actor
var action_targets = []
var targeted_cell_range = []
var action_state = ACT.ActionState.Ready
export(String) var action_name
export(int) var action_type = ACT.Type.None
export(int) var target_hints = ACT.TargetHint.None
export(float) var action_range = 1.5
export(float) var action_area = 0
export(int) var target_type = ACT.TargetType.TargetNone
export(int) var target_area = ACT.TargetArea.TargetSingle
export(Array, int) var target_priority = [ACT.TargetType.TargetTile, ACT.TargetType.TargetObject, ACT.TargetType.TargetItem, ACT.TargetType.TargetActor]
export(int) var target_cim = TIL.CellInteractions.Occupies
export(int) var x_cim = TIL.CellInteractions.Occupies
export(int) var c_cim = TIL.CellInteractions.BlocksFOV
export(float) var action_radius = 0.0
export(String) var pending_message = ""
export(String) var impossible_message = ""
export(String) var failed_message = ""
export(String) var success_message = ""
export(String) var impossible_log = ""
export(String) var failed_log = ""
export(String) var success_log = ""
export(String) var pertarget_log = ""

var running_effects = []
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_owned_by(actor):
	action_actor = actor
	
func set_target_types(target_types: Array) -> void:
	for individual_target_type in target_types:
		self.target_type |= individual_target_type

func get_target_hints(target_point:Vector2 = action_actor.game_position):
	if target_area == ACT.TargetArea.TargetCone:
		var hint_area = FOV.cast_area(action_actor.game_position, action_range, c_cim, x_cim)
		var effect_area = FOV.cast_psuedo_cone(action_actor.game_position, target_point, action_area, action_range, c_cim, x_cim)
		hint_area.erase(action_actor.game_position)
		var valid_area = [action_actor.game_position]
		for cell in effect_area:
			var cell_targets = WRLD.get_action_targets_cell(self, cell)
			if cell_targets.size() > 0:
				valid_area.append(cell)
		for cell in valid_area:
			effect_area.erase(cell)
		return [hint_area, effect_area, valid_area]
	elif target_area == ACT.TargetArea.TargetNone:
		return [[],[],[action_actor.game_position]]
	elif target_area == ACT.TargetArea.TargetSingle:
		var hint_area = FOV.cast_area(action_actor.game_position, action_range, target_cim, x_cim)
		var valid_area = []
		hint_area.erase(target_point)
		for cell in hint_area:
			var cell_targets = WRLD.get_action_targets_cell(self, cell)
			if cell_targets.size() > 0:
				valid_area.append(cell)
		var best_cell = null
		var best_distance = INF
		for cell in valid_area:
			var cds = cell.distance_squared_to(target_point)
			if cds < best_distance:
				best_distance = cds
				best_cell = cell
		var target_hint = []
		if best_cell:
			target_hint.append(best_cell)
		valid_area.erase(target_point)
		return [[], target_hint, valid_area]
	elif target_area == ACT.TargetArea.TargetCell: 
		if target_point.distance_to(action_actor.game_position) > action_range:
			target_point = FOV.cast_nearest_point(action_actor.game_position, target_point, action_range, target_cim, x_cim)
		var hint_area = FOV.cast_area(action_actor.game_position, action_range, target_cim, x_cim)
		var effect_area = [target_point]
		var valid_area = []
		for cell in hint_area:
			var cell_targets = WRLD.get_action_targets_cell(self, cell)
			if cell_targets.size() > 0:
				valid_area.append(cell)
		for cell in valid_area:
			hint_area.erase(cell)
		return [hint_area, effect_area, valid_area]
	elif target_area == ACT.TargetArea.TargetWideBeam:
		var hint_area = FOV.cast_area(action_actor.game_position, action_range, target_cim, x_cim)
		var effect_area = FOV.cast_wide_beam(action_actor.game_position, target_point, action_area, action_range, target_cim, x_cim)
		var valid_area = []
		for cell in effect_area:
			var cell_targets = WRLD.get_action_targets_cell(self, cell)
			if cell_targets.size() > 0:
				valid_area.append(cell)
		for cell in valid_area:
			effect_area.erase(cell)
		return [hint_area, effect_area, valid_area]
	elif target_area == ACT.TargetArea.TargetSelf:
		return [[], [], [action_actor.game_position]]

func get_viable_targets():
	pass

func complete():
	pass

func get_origin_cell():
	return self.action_actor.game_position

func action_viable():
	if target_hints & ACT.TargetHint.StaminaSpender and action_actor.game_stats.get_resource(GameStats.STAMINA) <= 0:
		if action_actor.is_player:
			MSG.action_message(self, "{subject} don't have enough stamina!")
		return false
	return true

func do_action_at(target_cell):
	if not action_viable():
		impossible()
		return false
	var targets = []
	action_targets = []
	targeted_cell_range = []
	if target_area == ACT.TargetArea.TargetCell or target_area == ACT.TargetArea.TargetSingle:
		if action_actor.game_position.distance_to(target_cell) > action_range:
			target_cell = FOV.cast_nearest_point(action_actor.game_position, target_cell, action_range, target_cim, x_cim)
		targeted_cell_range = [target_cell]
		targets = WRLD.get_action_targets_cell(self, target_cell)
		if targets.size() == 0:
			var oct_cast = FOV.cast_oct(action_actor.game_position, target_cell, action_range, target_cim, x_cim)
			var best_targets = null
			var best_dist = INF
			var best_cell = null
			for cell in oct_cast:
				var cell_targets = WRLD.get_action_targets_cell(self, cell)
				if cell_targets.size() > 0:
					var cds = action_actor.game_position.distance_squared_to(cell)
					if cds < best_dist:
						best_dist = cds
						best_targets = cell_targets
						best_cell = cell
			if best_targets:
				targets = best_targets
				targeted_cell_range = [best_cell]
	elif target_area == ACT.TargetArea.TargetCone:
		targeted_cell_range = WRLD.get_cone_action_cells(self, target_cell)
		for target_cell in targeted_cell_range:
			targets.append_array(WRLD.get_action_targets_cell(self, target_cell))
	elif target_area == ACT.TargetArea.TargetSelf and target_cell == action_actor.game_position:
		targets = [action_actor]
	if not post_validate(targets):
		self.impossible()
		return false
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
	elif target_area == ACT.TargetArea.TargetCell or target_area == ACT.TargetArea.TargetCone:
		var actual_targets = []
		for target in targets:
			if !actual_targets.has(target):
				actual_targets.append(target)
		self.do_action(targets)
		return true
	elif target_area == ACT.TargetArea.TargetSelf:
		if targets.size() == 1 and targets[0] == action_actor:
			self.do_action(targets)
			return true
	self.impossible()
	return false

func post_validate(targets):
	return true

func test_action_at(at_cell):
	if action_actor.game_position.distance_to(at_cell) > action_range:
		return false
	var targets = WRLD.get_action_targets_cell(self, at_cell)
	if targets.size() == 0:
		return false
	return true

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
	if self.failed_message != "":
		MSG.action_message(self, self.failed_message)
	if self.failed_log != "":
		MSG.action_log(self, self.failed_log)
	self.action_state = ACT.ActionState.Failed

func mark_pending():
	if self.pending_message != "":
		MSG.action_message(self, self.pending_message)
	EVNT.emit_signal("hint_action", self)
	
func impossible():
	if self.impossible_message != "":
		MSG.action_message(self, self.impossible_message)
	if self.impossible_log != "":
		MSG.action_log(self, self.impossible_log)
	self.action_state = ACT.ActionState.Impossible
	EVNT.emit_signal("action_impossible", self)

func do():
	pass

func execute():
	if target_hints & ACT.TargetHint.StaminaSpender:
		action_actor.game_stats.change_resource(GameStats.STAMINA, -1)
	self.do()
	if self.success_message != "":
		MSG.action_message(self, self.success_message)
	if self.success_log != "":
		MSG.action_log(self, self.success_log)
	self.finish()

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
