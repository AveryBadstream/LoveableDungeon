extends Sprite

class_name GameObject

signal  actor_did_action(actor, object, action_type, success)

export(ACT.Type) var default_action := ACT.Type.Move
export var display_name := "ERROR"
export var is_walkable := false
export var is_flyable := false
export var is_phaseable := false
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
	position = new_position * 16
	
func get_game_position() -> Vector2:
	return position / 16
	
func check_adjacent(object):
	return (self.game_position - object.game_position).length() == 1
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
