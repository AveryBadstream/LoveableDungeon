extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_IndoorBSP_mst_build(path_zones):
	for p in path_zones.get_points():
		for c in path_zones.get_point_connections(p):
			var pp = path_zones.get_point_position(p) * 16
			var cp = path_zones.get_point_position(c) * 16
			var new_segment = Line2D.new()
			new_segment.add_point(pp)
			new_segment.add_point(cp)
			add_child(new_segment)
