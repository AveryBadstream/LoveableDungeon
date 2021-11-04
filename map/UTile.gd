extends Reference

class_name UTile

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const thing_type = ACT.TargetType.TargetTile
var default_action = ACT.Type.None
var display_name = "ERROR"
var supported_actions = []
var cell_mask_properties:int = TIL.CellInteractions.None
export var is_walkable := false
export var is_flyable := false
export var is_phaseable := false
export var occupies_cell := true
export var blocks_vision := false
var claiming_effects = []
var cell_interaction_mask = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var game_position: Vector2

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _init(name, is_walkable, is_flyable, is_phaseable, blocks_fov, occupies_cell):
	self.display_name = name
	if is_walkable:
		self.supported_actions.append(ACT.Type.Move)
		self.default_action = ACT.Type.Move
	if is_flyable:
		self.supported_actions.append(ACT.Type.Fly)
	if is_phaseable:
		self.supported_actions.append(ACT.Type.Phase)
	if blocks_fov:
		self.blocks_vision = true
	if occupies_cell:
		self.occupies_cell = true
	if blocks_fov:
		cell_interaction_mask |= TIL.CellInteractions.BlocksFOV
	if is_walkable:
		cell_interaction_mask |= TIL.CellInteractions.Walkable
	if is_flyable:
		cell_interaction_mask |= TIL.CellInteractions.Flyable
	if is_phaseable:
		cell_interaction_mask |= TIL.CellInteractions.Phaseable
	if occupies_cell:
		cell_interaction_mask |= TIL.CellInteractions.Occupies

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

func effect_pre(effect):
	return null

func effect_post(effect):
	return null

func effect_claim(effect):
	claiming_effects.append(effect)

func effect_release(effect):
	claiming_effects.erase(effect)

func do_action(action) -> int:
	if self.has_method("_do_action"+ACT.Type.keys()[action.action_type]):
		return self.call("_do_action" + ACT.Type.keys()[action.action_type], action)
	elif supported_actions.has(action.action_type):
		return ACT.ActionResponse.Proceed
	else:
		return ACT.ActionResponse.Stop

func actor_do_action(actor, action_type:int) -> bool:
	return self.call("_actor_do_" + ACT.Type.keys()[action_type], actor)

func object_entered(object, from_cell):
	pass

# Called when the node enters the scene tree for the first time.
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
