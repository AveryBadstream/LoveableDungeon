extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum Type {Floor, Wall, Ground, Rock}

const TILE_WALKABLE = [1,0,1,0]
const TILE_FLYABLE = [1,0,1,0]
const TILE_PHASEABLE = [1,1,1,0]
const TILE_BLOCK_FOV = [0,1,0,1]
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
