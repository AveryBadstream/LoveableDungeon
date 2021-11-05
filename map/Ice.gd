extends UTile


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var slip_effect = preload("res://effects/Slip.gd")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func _init(name, is_walkable, is_flyable, is_phaseable, blocks_fov, occupies_cell).(name, is_walkable, is_flyable, is_phaseable, blocks_fov, occupies_cell):
	pass

func _trigger_EndedMovement(trigger_details):
	var target = trigger_details.triggered_by
	var from_cell = trigger_details.from_cell
	var to_cell = trigger_details.to_cell
	var direction = (to_cell  - from_cell).normalized()
	EFCT.queue_next(slip_effect.new(self, target, direction))
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
