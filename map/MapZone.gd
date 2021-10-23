extends Reference

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var rect: Rect2
var children := []
var features := []
var neighbors := []
var zone_path = AStar2D.new()
var leaf :bool setget , get_leaf
var left setget set_left, get_left
var right setget set_right, get_right
var center setget set_center, get_center
var parent = null
var depth: int = 0
var tree_node = false
var traversed = false
var build_rng
var path_id := -1

func _init(area: Rect2) -> void:
	self.rect = area

func set_parent(parent_zone) -> void:
	parent = parent_zone
	depth = parent.depth + 1

func place_feature(feature: Rect2) -> bool:
	if leaf:
		return false
	if feature.size.x > rect.size.x:
		feature.size.x = rect.size.x
		feature.position.x = rect.position.x
	if feature.size.y > rect.size.y:
		feature.size.y = rect.size.y
		feature.position.y = rect.position.y
	if feature.position == rect.position and feature.size == rect.size:
		features.append(feature)
		return true
	var corners = [build_rng.randi() % 2, build_rng.randi() % 2, build_rng.randi() % 2, build_rng.randi() % 2]
	var MapZone = load(get_script().resource_path)
	var next_child = MapZone.new(feature)
	next_child.parent = self
	next_child.features.append(feature)
	children.append(next_child)
	var left_margin = feature.position.x - rect.position.x
	var top_margin = feature.position.y - rect.position.y
	var right_margin = rect.end.x - feature.end.x
	var bottom_margin = rect.end.y - feature.end.y
	assert(left_margin>-1)
	assert(top_margin>-1)
	assert(right_margin>-1)
	assert(bottom_margin>-1)
	var child_start
	var child_end
	if left_margin:
		child_start = Vector2(rect.position.x, feature.position.y)
		child_end = Vector2(feature.position.x, feature.end.y)
		if top_margin and !corners[0]:
			child_start.y = rect.position.y
		if bottom_margin and corners[3]:
			child_end.y = rect.end.y
		next_child = MapZone.new(Rect2(child_start, child_end - child_start))
		next_child.parent = self
		children.append(next_child)
	if top_margin:
		child_start = Vector2(feature.position.x, rect.position.y)
		child_end = Vector2(feature.end.x, feature.position.y)
		if right_margin and !corners[1]:
			child_end.x = rect.end.x
		if left_margin and corners[0]:
			child_start.x = rect.position.x
		next_child = MapZone.new(Rect2(child_start, child_end - child_start))
		next_child.parent = self
		children.append(next_child)
	if right_margin:
		child_start = Vector2(feature.end.x, feature.position.y)
		child_end = Vector2(rect.end.x, feature.end.y)
		if bottom_margin and !corners[2]:
			child_end.x = rect.end.x
		if top_margin and corners[1]:
			child_start.y = rect.position.y
		next_child = MapZone.new(Rect2(child_start, child_end - child_start))
		next_child.parent = (self)
		children.append(next_child)
	if bottom_margin:
		child_start = Vector2(feature.position.x, feature.end.y)
		child_end = Vector2(feature.end.x, rect.end.y)
		if right_margin and !corners[2]:
			child_end.x = rect.end.x
		if left_margin and corners[3]:
			child_start.x = rect.position.x
		next_child = MapZone.new(Rect2(child_start, child_end - child_start))
		next_child.parent = (self)
		children.append(next_child)
	return true

func mark_if_adjacent(zone):
	if zone != self and self.rect.intersects(zone.rect, true):
		if !neighbors.has(zone):
			self.neighbors.append(zone)
		return true
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

func set_center(center_point: Vector2):
	self.position = center_point - (rect.size / 2)

func get_center():
	return (rect.size / 2) + rect.position
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
