extends Node

var GameWorld = null
var TMap = null
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func is_tile_walkable(tile_position):
	return TMap.is_tile_walkable(tile_position)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
