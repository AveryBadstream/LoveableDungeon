extends Node

var GameWorld = null
var TMap = null
var world_dimensions = Vector2(0,0)

enum GeneratorSignal {MapDimension}
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const SIGHT_RANGE = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func is_tile_walkable(tile_position):
	return TMap.is_tile_walkable(tile_position)

func _on_export_generator_config(config_type, config_value):
	if config_type == GeneratorSignal.MapDimension:
		world_dimensions = config_value
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
