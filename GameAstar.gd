extends AStar

class_name GameAstar
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_point_connections(id: int) -> PoolIntArray:
	return .get_point_connections(id)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
