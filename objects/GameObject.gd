extends Sprite

class_name GameObject

signal actor_did_action(actor, object, action_type, success)
signal toggle(myself)

export(ACT.Type) var default_action := ACT.Type.Move
export var display_name := "ERROR"
export var is_walkable := false
export var is_flyable := false
export var is_phaseable := false
var is_player := false
export(bool) var blocks_vision setget set_blocks_vision, get_blocks_vision
export var player_remembers := false

var tentatively_visible = false
var my_ghost
var _blocks_vision = false
var thing_type = ACT.TargetType.TargetObject
export(Array, ACT.Type) var supported_actions
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var game_position: Vector2 setget set_game_position, get_game_position

func supports_action(action) -> bool:
	var funcname = "_can_support_"+ACT.Type.keys()[action.action_type]
	if self.has_method(funcname):
		return self.call(funcname, action)
	elif supported_actions.has(action.action_type):
		return ACT.ActionResponse.Proceed
	else:
		return ACT.ActionResponse.Stop

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
	EVNT.subscribe("begin_fov", self, "_on_begin_fov")
	EVNT.subscribe("update_fov_cell", self, "_on_update_fov_cell")
	if self.player_remembers:
		EVNT.subscribe("end_fov", self, "_on_end_fov_and_ghost")
	else:
		EVNT.subscribe("end_fov", self, "_on_end_fov")
	if self.get_blocks_vision():
		EVNT.emit_signal("update_visible_map", get_game_position(), true)

func _on_begin_fov():
	self.tentatively_visible = false

func _on_update_fov_cell(cell):
	if cell == self.get_game_position():
		self.tentatively_visible = true

func _on_end_fov_and_ghost():
	if tentatively_visible and my_ghost:
		EVNT.emit_signal("end_ghost", my_ghost)
		my_ghost = null
	elif !tentatively_visible and !my_ghost:
		var new_ghost = FOWGhost.new()
		new_ghost.set_mimic(self)
		EVNT.emit_signal("create_ghost", new_ghost)
		my_ghost = new_ghost
	self.set_visible(tentatively_visible)

func _on_end_fov():
	self.set_visible(tentatively_visible)

func set_game_position(new_position: Vector2):
	var old_position = get_game_position()
	if new_position == old_position:
		return
	if self.blocks_vision:
		EVNT.emit_signal("update_visible_map", get_game_position(), false)
		self.position = new_position * 16
		EVNT.emit_signal("update_visible_map", get_game_position(), true)
		EVNT.emit_signal("update_fov")
	self.position = new_position * 16
	EVNT.emit_signal("object_moved", self, old_position)

func get_game_position() -> Vector2:
	return self.position / 16

func set_blocks_vision(should_block):
	if _blocks_vision != should_block:
		EVNT.emit_signal("update_visible_map", get_game_position(), should_block)
		_blocks_vision = should_block

func get_blocks_vision():
	return _blocks_vision

func connect_to(target_object):
	self.connect("toggle", target_object, "_on_toggle")

func _on_toggle(toggled_by):
	pass

func check_adjacent(object):
	return (self.game_position - object.game_position).length() == 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
