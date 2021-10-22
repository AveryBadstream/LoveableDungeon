extends Reference

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var rect: Rect2
var children := []
var features := []
var leaf :bool setget , get_leaf
var left setget set_left, get_left
var right setget set_right, get_right
var parent = null
var depth: int = 0
var tree_node = false
var traversed = false

func _init(area: Rect2) -> void:
	self.rect = area

func set_parent(parent_zone) -> void:
	parent = parent_zone
	depth = parent.depth + 1

func place_feature(feature: Rect2) -> bool:
	if feature.position.x >= rect.position.x \
		and feature.position.y >= rect.position.y \
		and feature.end.x <= rect.end.x \
		and feature.end.y <= rect.end.y:
		self.features.append(feature)
		return true
	else:
		return false
		
func get_left():
	if children.size() >= 1:
		return children[0]
	return null

func set_left(left_child):
	if children.size() == 0:
		children.append(left_child)
	else:
		children[0] = left_child

func get_right():
	if children.size() >= 2:
		return children[1]
	return null

func set_right(right_child):
	if children.size() == 0:
		children.append(null)
		children.append(right_child)
	elif children.size() == 1:
		children.append(right_child)
	else:
		children[1] = right_child

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_leaf() -> bool:
	if self.children.size() == 0:
		return true
	else:
		return false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
