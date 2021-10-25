extends Reference

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var rect: Rect2
var children := []
var features := []
var neighbors := []
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
var connecting_points = []
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
	next_child.features.append(feature)
	self.add_child(next_child)
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
		if top_margin and corners[0]:
			child_start.y = rect.position.y
		if bottom_margin and !corners[3]:
			child_end.y = rect.end.y
		next_child = MapZone.new(Rect2(child_start, child_end - child_start))
		self.add_child(next_child)
	if top_margin:
		child_start = Vector2(feature.position.x, rect.position.y)
		child_end = Vector2(feature.end.x, feature.position.y)
		if right_margin and corners[1]:
			child_end.x = rect.end.x
		if left_margin and !corners[0]:
			child_start.x = rect.position.x
		next_child = MapZone.new(Rect2(child_start, child_end - child_start))
		self.add_child(next_child)
	if right_margin:
		child_start = Vector2(feature.end.x, feature.position.y)
		child_end = Vector2(rect.end.x, feature.end.y)
		if bottom_margin and corners[2]:
			child_end.y = rect.end.y
		if top_margin and !corners[1]:
			child_start.y = rect.position.y
		next_child = MapZone.new(Rect2(child_start, child_end - child_start))
		self.add_child(next_child)
	if bottom_margin:
		child_start = Vector2(feature.position.x, feature.end.y)
		child_end = Vector2(feature.end.x, rect.end.y)
		if right_margin and corners[3]:
			child_start.x = rect.position.x
		if left_margin and !corners[2]:
			child_end.x = rect.end.x
		next_child = MapZone.new(Rect2(child_start, child_end - child_start))
		self.add_child(next_child)
	return true

func place_connecting_feature(t_map):
	if(rect.position.x == 23 and rect.position.y == 42 and rect.size.x == 14 and rect.size.y == 3 ):
		pass
	if features.size() > 0:
		for connection in connecting_points:
			pass
			t_map.set_cell(connection.x, connection.y, TIL.Type.Floor)
		return
	assert(features.size() == 0)
	if connecting_points.size() == 2:
		corridor_points(t_map, connecting_points[0], connecting_points[1])
		return
	elif connecting_points.size() == 1:
		corridor_points(t_map, connecting_points[0], Vector2(int(self.center.x), int(self.center.y)))
		return
	for i in range(connecting_points.size()):
		corridor_points(t_map, connecting_points[i], Vector2(int(self.center.x), int(self.center.y)))

func corridor_points(t_map, from_p, to_p):
	var walk_point = from_p
	t_map.set_cell(from_p.x, from_p.y, TIL.Type.CaveFloor)
	walk_point = from_p
	while walk_point != to_p:
		if walk_point.x == to_p.x:
			walk_point.y += int(clamp(to_p.y - walk_point.y, -1, 1))
		elif walk_point.y == to_p.y:
			walk_point.x += int(clamp(to_p.x - walk_point.x, -1, 1))
		elif build_rng.randi() % 2:
			walk_point.y += int(clamp(to_p.y - walk_point.y, -1, 1))
		else:
			walk_point.x += int(clamp(to_p.x - walk_point.x, -1, 1))
		t_map.set_cell(walk_point.x, walk_point.y, TIL.Type.CaveFloor)

func connect_to_neighbor(neighbor):
	if !neighbors.has(neighbor):
		return false
	var connection
	var am_room = features.size() * 2
	var n_room = neighbor.features.size() * 2
	if neighbor.rect.end.x == rect.position.x: #Neighbor is to the left
		connection = Vector2(rect.position.x, build_rng.randi_range(max(rect.position.y + am_room, neighbor.rect.position.y + n_room), min(rect.end.y - 1 - am_room , neighbor.rect.end.y - 1 - n_room)))
		neighbor.connecting_points.append(connection + Vector2.LEFT)
	elif neighbor.rect.end.y == rect.position.y: #Neighbor is to the up
		connection = Vector2(build_rng.randi_range(max(rect.position.x + am_room, neighbor.rect.position.x + n_room), min(rect.end.x - 1 - am_room, neighbor.rect.end.x - 1 - n_room)), rect.position.y)
		neighbor.connecting_points.append(connection + Vector2.UP)
	elif neighbor.rect.position.x == rect.end.x: #Neighbor is to the right
		connection = Vector2(rect.end.x - 1, build_rng.randi_range(max(rect.position.y + am_room, neighbor.rect.position.y + n_room), min(rect.end.y - 1 - am_room, neighbor.rect.end.y - 1 - n_room)))
		neighbor.connecting_points.append(connection + Vector2.RIGHT)
	elif neighbor.rect.position.y == rect.end.y: #Neighbor is to the down
		connection = Vector2(build_rng.randi_range(max(rect.position.x + am_room, neighbor.rect.position.x + n_room), min(rect.end.x - 1 - am_room, neighbor.rect.end.x - 1 - n_room )), rect.end.y - 1)
		neighbor.connecting_points.append(connection + Vector2.DOWN)
	else:
		return false
	self.connecting_points.append(connection)
	return connection

func mark_if_adjacent(zone):
	if zone != self and self.rect.intersects(zone.rect, true):
		if self.features.size() or zone.features.size():
			if (rect.position.x == zone.rect.end.x or rect.end.x == zone.rect.position.x) and (zone.rect.end.y - rect.position.y == 1 or rect.end.y - zone.rect.position.y == 1 ): #Left or Right neighbor
				return false #not able to connect reliably
			elif (rect.position.y == zone.rect.end.y or rect.end.y == zone.rect.position.y) and (zone.rect.end.x - rect.position.x == 1 or rect.end.x - zone.rect.position.x == 1 ): #Up or Down neighbor
				return false #not able to connect reliably
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

func add_child(child, child_i = -1) -> bool:
	if children.has(child):
		return false
	if child_i >= 0 and child_i < children.size():
		children[child_i] = child
		child.parent = self
		child.depth = self.depth + 1
		return true
	if child_i < 0 or child_i == children.size():
		children.append(child)
		child.parent = self
		child.depth = self.depth + 1
		return true
	if child_i > children.size():
		for i in range(children.size(), child_i):
			children.append(null)
		children.append(child)
		child.parent = self
		child.depth = self.depth + 1
		return true
	return false
		

func set_center(center_point: Vector2):
	self.position = center_point - (rect.size / 2)

func get_center():
	return (rect.size / 2) + rect.position
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
