extends Reference

class_name ITile

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var game_position: Vector2
var actual_utile
var claiming_effects = []
const thing_type = ACT.TargetType.TargetTile
const is_player = false
const is_immovable = true

var blocks_vision setget , get_blocks_vision

var default_action setget ,get_default_action
var cell_interaction_mask setget ,get_cell_interaction_mask
var display_name setget ,get_display_name
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_display_name():
	return actual_utile.display_name

func get_cell_interaction_mask():
	return actual_utile.cell_interaction_mask

func get_blocks_vision():
	return actual_utile.blocks_vision

func get_default_action():
	return self.actual_utile.default_action

func _init(parent_utile, at_cell):
	self.actual_utile = parent_utile
	self.game_position = at_cell

func trigger(trigger_details):
	actual_utile.trigger(trigger_details)

func supports_action(action) -> bool:
	return actual_utile.supports_action(action)

func can_do_action(action) -> bool:
	return actual_utile.can_do_action(action)

func do_action_pre(action) -> int:
	return actual_utile.do_action_pre(action)

func do_action_post(action) -> int:
	return actual_utile.do_action_post(action)

func do_action(action) -> int:
	return actual_utile.do_action(action)

func effect_pre(effect):
	return actual_utile.effect_pre(effect)

func effect_post(effect):
	return actual_utile.effect_post(effect)

func effect_claim(effect):
	claiming_effects.append(effect)

func effect_release(effect):
	claiming_effects.erase(effect)

func show():
	actual_utile.show()

func hide():
	actual_utile.hide()
