extends Reference

class_name GameTile

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const thing_type = ACT.TargetType.TargetTile
var default_action = ACT.Type.None
var display_name = "ERROR"
var supported_actions = []
var blocks_vision = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var game_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _init(at_cell:Vector2, tile_type):
	if TIL.TILE_WALKABLE[tile_type]:
		self.supported_actions.append(ACT.Type.Move)
	if TIL.TILE_FLYABLE[tile_type]:
		self.supported_actions.append(ACT.Type.Fly)
	if TIL.TILE_PHASEABLE[tile_type]:
		self.supported_actions.append(ACT.Type.Phase)
	if TIL.TILE_BLOCK_FOV[tile_type]:
		self.blocks_vision = true
	self.game_position = at_cell

func supports_action(action) -> bool:
	if self.has_method("_can_support_"+ACT.Type.keys()[action.action_type]):
		return self.call("_can_support_"+ACT.Type.keys()[action.action_type], action)
	elif supported_actions.has(action.action_type):
		return ACT.ActionResponse.Proceed
	else:
		return ACT.ActionResponse.Stop

func can_do_action(action) -> bool:
	if self.has_method("_can_do_"+ACT.Type.keys()[action.action_type]):
		return self.call("_can_do_" + ACT.Type.keys()[action.action_type], action)
	elif supported_actions.has(action.action_type):
		return ACT.ActionResponse.Proceed
	else:
		return ACT.ActionResponse.Stop

func do_action_pre(action) -> int:
	if self.has_method("_do_action_pre_"+ACT.Type.keys()[action.action_type]):
		return self.call("_do_action_pre_" + ACT.Type.keys()[action.action_type], action)
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
	if self.has_method("_do_action"+ACT.Type.keys()[action.action_type]):
		return self.call("_do_action" + ACT.Type.keys()[action.action_type], action)
	elif supported_actions.has(action.action_type):
		return ACT.ActionResponse.Proceed
	else:
		return ACT.ActionResponse.Stop

func actor_do_action(actor, action_type:int) -> bool:
	return self.call("_actor_do_" + ACT.Type.keys()[action_type], actor)

# Called when the node enters the scene tree for the first time.
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
