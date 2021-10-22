extends CanvasLayer

signal shift_leaf(by)
signal get_leaf_index(i)
signal build_tree(tree)
var current_leaf = 0
onready var LeafHighlighter = $Hider/LeafHighlight
onready var RectHighlighter = $Hider/RectHighlight
onready var NodeTree = $Hider/NodeLayer/NodeTree

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _input(event):
	if !event.is_pressed():
		return
	if event.is_action("menu_toggle"):
		$Hider.visible = !$Hider.visible
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func world_ready():
	emit_signal("build_tree", NodeTree)

func highlight_room(room):
	LeafHighlighter.set_global_position(room.position * 16)
	LeafHighlighter.set_size(room.size * 16)

func _on_NodeTree_item_selected():
	RectHighlighter.set_global_position(NodeTree.get_selected().get_metadata(0)["rect"].position * 16)
	RectHighlighter.set_size(NodeTree.get_selected().get_metadata(0)["rect"].size * 16)


func _on_NextLeaf_pressed():
	emit_signal("shift_leaf", + 1)


func _on_PreviousLeaf_pressed():
	emit_signal("shift_leaf", - 1) # Replace with function body.

func _on_HighlightLeaf_pressed():
	LeafHighlighter.visible = !LeafHighlighter.visible
