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

var blocks_vision setget , get_blocks_vision

var default_action setget ,get_default_action
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_blocks_vision():
	return actual_utile.blocks_vision

func get_default_action():
	return self.actual_utile.default_action

func _init(parent_utile, at_cell):
	self.actual_utile = parent_utile
	self.game_position = at_cell

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


# Called when the node enters the scene tree for the first time.
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
