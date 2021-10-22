extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var NodeTree = get_node("../NodeLayer/NodeTree")
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_NodeTree_item_selected():
	var cur_node = NodeTree.get_selected()
	var zone = cur_node.get_metadata(0)
	if zone.features.size() > 0:
		visible = true
		set_global_position(zone.features[0].position * 16)
		set_size(zone.features[0].size * 16) # Replace with function body.
	else:
		visible = false
