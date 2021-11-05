extends Sprite

class_name GameObject

signal actor_did_action(actor, object, action_type, success)
signal toggle(myself)
signal position_update_complete()

const is_action = false

export(ACT.Type) var default_action := ACT.Type.Move
export var display_name := "ERROR"
export var is_walkable := false
export var is_flyable := false
export var is_phaseable := false
export var occupies_cell := true
var is_player := false
export(bool) var blocks_vision setget set_blocks_vision, get_blocks_vision
export var player_remembers := false
var last_game_position = position/16
var connects_to = []
var claiming_effects = []
var cell_interaction_mask = 0
var tentatively_visible = false
var my_ghost
var _blocks_vision = false
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

# Called when the node enters the scene tree for the first time.
func _ready():
	if _blocks_vision:
		cell_interaction_mask |= TIL.CellInteractions.BlocksFOV
	if is_walkable:
		cell_interaction_mask |= TIL.CellInteractions.Walkable
	if is_flyable:
		cell_interaction_mask |= TIL.CellInteractions.Flyable
	if is_phaseable:
		cell_interaction_mask |= TIL.CellInteractions.Phaseable
	if occupies_cell:
		cell_interaction_mask |= TIL.CellInteractions.Occupies
	EVNT.emit_signal("update_cimmap", self)

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

func set_game_position(new_position: Vector2, update_real_position=true, update_fov=true):
	if new_position != last_game_position:
		if self.blocks_vision:
			EVNT.emit_signal("update_visible_map", last_game_position, false)
			EVNT.emit_signal("update_visible_map", new_position, true)
			if update_fov:
				EVNT.emit_signal("update_fov")
			#yield(WRLD.GameWorld, "end_fov")
		if update_real_position:
			self.position = new_position * 16
		last_game_position = new_position
		EVNT.emit_signal("object_moved", self, last_game_position)
	emit_signal("position_update_complete")

func get_game_position() -> Vector2:
	return last_game_position

func set_blocks_vision(should_block):
	if _blocks_vision != should_block:
		EVNT.emit_signal("update_visible_map", get_game_position(), should_block)
		_blocks_vision = should_block

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
