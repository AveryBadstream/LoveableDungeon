extends Sprite

class_name GameObject

signal actor_did_action(actor, object, action_type, success)
signal toggle(myself)
signal position_update_complete()

const is_action = false

export(ACT.Type) var default_action := ACT.Type.Move
export(String) var display_name := "ERROR"
export(bool) var is_walkable setget set_is_walkable, get_is_walkable
export(bool) var is_flyable setget set_is_flyable, get_is_flyable
export(bool) var is_phaseable setget set_is_phaseable, get_is_phaseable
export(bool) var occupies_cell setget set_occupies_cell, get_occupies_cell
var is_player := false
export(bool) var blocks_vision setget set_blocks_vision, get_blocks_vision
export var player_remembers := false
var last_game_position = position/16
var _game_position = last_game_position
var connects_to = []
var claiming_effects = []
var cell_interaction_mask setget ,get_cim
var tentatively_visible = false
var my_ghost
var _blocks_vision = false
var _is_walkable = false
var _is_flyable = false
var _is_phaseable = false
var _occupies_cell = false
var triggers = []
var thing_type = ACT.TargetType.TargetObject
export(Array, ACT.Type) var supported_actions
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var game_position: Vector2 setget set_game_position, get_game_position

func set_initial_game_position(at_cell:Vector2):
	position = at_cell * 16
	last_game_position = at_cell

func supports_action(action) -> bool:
	var funcname = "_can_support_"+ACT.Type.keys()[action.action_type]
	if self.has_method(funcname):
		return self.call(funcname, action)
	elif supported_actions.has(action.action_type):
		return ACT.ActionResponse.Proceed
	else:
		return ACT.ActionResponse.Stop

func effect_pre(effect):
	return null

func effect_post(effect):
	return null

func effect_claim(effect):
	claiming_effects.append(effect)

func effect_release(effect):
	claiming_effects.erase(effect)

func can_do_action(action) -> bool:
	var funcname = "_can_do_"+ACT.Type.keys()[action.action_type]
	if self.has_method(funcname):
		return self.call(funcname, action)
	elif supported_actions.has(action.action_type):
		return ACT.ActionResponse.Proceed
	else:
		return ACT.ActionResponse.Stop

func trigger(trigger_details):
	var funcname = "_trigger_"+ EVNT.TriggerType.keys()[trigger_details.trigger_type]
	if self.has_method(funcname):
		self.call(funcname, trigger_details)
	for ext_trigger in self.triggers:
		if ext_trigger.trigger_type == trigger_details.trigger_type:
			call(ext_trigger.trigger_func_ref, trigger_details)

func do_action_pre(action) -> int:
	var func_name = "_do_action_pre_"+ACT.Type.keys()[action.action_type]
	if self.has_method(func_name):
		return self.call(func_name, action)
	elif supported_actions.has(action.action_type):
		return ACT.ActionResponse.Proceed
	else:
		return ACT.ActionResponse.Stop

func do_action_post(action) -> int:
	if self.has_method("_do_action_post_"+ACT.Type.keys()[action.action_type]):
		return self.call("_do_action_post_" + ACT.Type.keys()[action.action_type], action)
	elif supported_actions.has(action.action_type):
		return ACT.ActionResponse.Proceed
	else:
		return ACT.ActionResponse.Stop

func do_action(action) -> int:
	var funcname = "_do_action_"+ACT.Type.keys()[action.action_type]
	if self.has_method(funcname):
		return self.call(funcname, action)
	elif supported_actions.has(action.action_type):
		return ACT.ActionResponse.Proceed
	else:
		return ACT.ActionResponse.Stop

func actor_do_action(actor, action_type:int) -> bool:
	return self.call("_actor_do_" + ACT.Type.keys()[action_type], actor)

func get_cim():
	var cim = 0
	if _blocks_vision:
		cim |= TIL.CellInteractions.BlocksFOV
	if _is_walkable:
		cim |= TIL.CellInteractions.Walkable
	if _is_flyable:
		cim |= TIL.CellInteractions.Flyable
	if _is_phaseable:
		cim |= TIL.CellInteractions.Phaseable
	if _occupies_cell:
		cim |= TIL.CellInteractions.Occupies
	return cim


func hide():
	if player_remembers and !my_ghost:
		var new_ghost = FOWGhost.new()
		new_ghost.set_mimic(self)
		EVNT.emit_signal("create_ghost", new_ghost)
		my_ghost = new_ghost
	.hide()

func show():
	if player_remembers and my_ghost:
		EVNT.emit_signal("end_ghost", my_ghost)
		my_ghost = null
	.show()

func set_game_position(new_position: Vector2, update_real_position=true):
	if new_position != last_game_position:
		if update_real_position:
			self.position = new_position * 16
		var last_last_game_position = last_game_position
		last_game_position = new_position
		EVNT.emit_signal("object_moved", self, last_last_game_position, last_game_position)
	emit_signal("position_update_complete")

func get_game_position() -> Vector2:
	return last_game_position

func set_is_walkable(should_walk):
	if _is_walkable != should_walk:
		_is_walkable = should_walk
		EVNT.emit_signal("update_cimmap", self.get_game_position())
		
func get_is_walkable():
	return _is_walkable
	
func set_is_phaseable(should_phase):
	if _is_phaseable != should_phase:
		_is_phaseable = should_phase
		EVNT.emit_signal("update_cimmap", self.get_game_position())
		
func get_is_phaseable():
	return _is_phaseable
	
func set_is_flyable(should_fly):
	if _is_flyable != should_fly:
		_is_flyable = should_fly
		EVNT.emit_signal("update_cimmap", self.get_game_position())
		
func get_is_flyable():
	return _is_flyable
	
func set_occupies_cell(should_occupy):
	if _occupies_cell != should_occupy:
		_occupies_cell = should_occupy
		EVNT.emit_signal("update_cimmap", self.get_game_position())
		
func get_occupies_cell():
	return _occupies_cell

func set_blocks_vision(should_block):
	if _blocks_vision != should_block:
		_blocks_vision = should_block
		EVNT.emit_signal("update_cimmap", self.get_game_position())
		
func get_blocks_vision():
	return _blocks_vision

func connect_to(target_object):
	self.connects_to.append(target_object)

func _on_toggle(toggled_by):
	pass

func check_adjacent(object):
	return (self.game_position - object.game_position).length() == 1

func effect_done(effect):
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
