extends UTile


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
func _init(is_walkable, is_flyable, is_phaseable, blocks_fov).(is_walkable, is_flyable, is_phaseable, blocks_fov):
	pass

func object_entered(object, from_cell):
	var to_cell = object.game_position  - (from_cell  - object.game_position).normalized()
	if WRLD.is_tile_walkable(to_cell):
		object.game_position = to_cell

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
