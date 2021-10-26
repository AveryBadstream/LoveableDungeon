extends Sprite

class_name GameObject

signal actor_did_action(actor, object, action_type, success)

export(ACT.Type) var default_action := ACT.Type.Move
export var display_name := "ERROR"
export var is_walkable := false
export var is_flyable := false
export var is_phaseable := false
export(bool) var blocks_vision setget set_blocks_vision, get_blocks_vision
export var mimics_tile := false

var _blocks_vision = false
export(Array, ACT.Type) var supported_actions
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var game_position: Vector2 setget set_game_position, get_game_position

func supports_action(action_type: int) -> bool:
	if supported_actions.has(action_type):
		return true
	return false

func can_actor_do_action(actor, action_type:int) -> bool:
	return self.call("_can_actor_do_" + ACT.Type.keys()[action_type], actor)

func actor_do_action(actor, action_type:int) -> bool:
	return self.call("_actor_do_" + ACT.Type.keys()[action_type], actor)

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_game_position(new_position: Vector2):
	var old_position = get_game_position()
	self.position = new_position * 16
	if self.blocks_vision:
		EVNT.emit_signal("update_object_vision_block", self, old_position, get_game_position(), true)
func get_game_position() -> Vector2:
	return self.position / 16

func set_blocks_vision(should_block):
	if _blocks_vision != should_block:
		EVNT.emit_signal("update_object_vision_block", self, null, self.get_game_position(), should_block)
		_blocks_vision = should_block

func get_blocks_vision():
	return _blocks_vision

func check_adjacent(object):
	return (self.game_position - object.game_position).length() == 1
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
