extends ColorRect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

onready var NodeTree: Tree = get_node("../NodeLayer/NodeTree")
onready var CenterMark: Sprite = get_node("../CenterMark")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_NodeTree_item_selected():
	var cur_node = NodeTree.get_selected()
	var rect = cur_node.get_metadata(0).rect
	set_global_position(rect.position * 16)
	set_size(rect.size * 16)
	CenterMark.position = (rect.position + (rect.size/2)) * 16
