extends TileMap

signal update_room_count(room_count)
signal update_current_room(current_room)
signal build_finished()
signal mst_build(path_zones)

onready var MapZone = preload("res://map/MapZone.gd")



# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var rooms = []
var toggle = false
var inspect_room = 0
var build_rng: RandomNumberGenerator
var path_zones = AStar2D.new()
var zones = []
var leafs = []
export(Vector2) var minimum_room_size
export(Vector2) var maximum_room_size
export(Vector2) var map_size
export(Vector2) var minimum_zone_size
export(Vector2) var maximum_zone_size
export(float, .1, .99, 0.01) var minimum_split_range
export(float, .2, 1.0, 0.01) var maximum_split_range
export(float, .1, .99, 0.01) var minimum_width_percent
export(float, .2, 1.00, 0.01) var maximum_width_percent
export(float, .1, .99, 0.01) var minimum_height_percent
export(float, .2, 1.00, 0.01) var maximum_height_percent
export(float, .0, .99, 0.01) var split_stop_chance
export(float, 0, 1.00, 0.1) var termina_loop_chance
export(int, 1, 1000) var max_failures
export(int, 1, 1000) var minimum_fail_depth
export(int, 0, 1000) var max_rectification_passes
enum TileType {Wall, Floor, CaveFloor, OpenDoor, Rock, ClosedDoor}


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func build_map(rng = null):
	var start_rect = Rect2(Vector2(0,0), map_size)
	var start_zone = MapZone.new(start_rect)
	rooms = []
	zones = [start_zone]
	fill_room(start_rect, TileType.Rock)
	var i = 0
	var fail_count = 0
	if rng == null:
		rng = RandomNumberGenerator.new()
		rng.seed = hash("broken")
	build_rng = rng
	while fail_count <= max_failures:
		var current_zone = zones[i]
		if current_zone.depth >= minimum_fail_depth:
			fail_count += 1
			continue
		if !bsp_split(current_zone):
			fail_count += 1
		if i == zones.size():
			var should_break = false
			while !zones[i].leaf:
				i += 1
				if i == zones.size():
					should_break = true
					break
		i += 1
	var rect_passes = 0
	var zones_to_split = find_bad_zones()
	var prev_stop_chance = split_stop_chance
	split_stop_chance = 0
	while rect_passes < max_rectification_passes and zones_to_split.size() > 0:
		for zone in zones_to_split:
			bsp_split(zone)
		zones_to_split = find_bad_zones()
		rect_passes += 1
	split_stop_chance = prev_stop_chance
	for zone in zones:
		if zone.leaf:
			leafs.append(zone)
	for zone in leafs:
		if zone.leaf:
			var room = make_room(zone.rect)
			rooms.append(room)
			zone.build_rng = build_rng
			if zone.place_feature(room) and !zone.leaf:
				zones.append_array(zone.children)
			fill_room(room, TileType.Floor)
			wall_room(room, TileType.Wall)
	leafs = []
	for zone in zones:
		if zone.leaf:
			leafs.append(zone)
			for zone2 in zones:
				zone.mark_if_adjacent(zone2)
	var mst_nodes = leafs.duplicate()
	var mst_zone = mst_nodes.pop_back()
	mst_zone.path_id = path_zones.get_available_point_id()
	path_zones.add_point(mst_zone.path_id, mst_zone.center)
	while mst_nodes:
		var min_dist = INF
		var min_p = null
		var p = null
		
		for point_id in path_zones.get_points():
			var point_pos = path_zones.get_point_position(point_id)
			
			for zone in mst_nodes:
				if point_pos.distance_to(zone.center) < min_dist:
					var neighbor = false
					for zone2 in leafs:
						if zone2.path_id == point_id:
							if zone in zone2.neighbors:
								neighbor = true 
					if not neighbor:
						continue
					min_dist = point_pos.distance_to(zone.center)
					min_p = zone
					p = point_id
		min_p.path_id = path_zones.get_available_point_id()
		path_zones.add_point(min_p.path_id, min_p.center)
		path_zones.connect_points(p, min_p.path_id)
		mst_nodes.erase(min_p)
		
	for zone in leafs:
		if !zone.features.size() and path_zones.get_point_connections(zone.path_id).size() > 1 and build_rng.randf() < termina_loop_chance:
			var candidates = []
			for neighbor in zone.neighbors:
				if !path_zones.are_points_connected(zone.path_id, neighbor.path_id):
					candidates.append(neighbor)
			if candidates.size() > 0:
				path_zones.connect_points(zone.path_id, candidates[build_rng.randi() % candidates.size()].path_id)
				
	emit_signal("mst_build", path_zones)

	update_bitmask_region(Vector2(0,0), map_size )
	emit_signal("build_finished")

func find_bad_zones():
	var zones_to_fix = []
	for zone in zones:
		if zone.leaf and (zone.rect.size.y > maximum_zone_size.x or zone.rect.size.x > maximum_zone_size.x):
			zones_to_fix.append(zone)
	return zones_to_fix

func build_rect_tree_display(node_tree):
	untraverse_zones()
	var root = zones[0]
	root.tree_node = node_tree.create_item()
	root.tree_node.set_text(0, String(root["rect"]))
	root.tree_node.set_metadata(0, root)
	root.traversed = true
	for zone in zones:
		if zone.traversed:
			continue
		else:
			zone.tree_node = node_tree.create_item( zone.parent.tree_node)
			zone.tree_node.set_text(0, String(zone.rect))
			zone.tree_node.set_metadata(0, zone)

func untraverse_zones():
	for zone in zones:
		zone.traversed = false


func make_room(room):
	var width = clamp(int(build_rng.randf_range(minimum_width_percent, maximum_width_percent) * room.size.x - 2), minimum_room_size.x, room.size.x - 1)
	var height = clamp(int(build_rng.randf_range(minimum_height_percent, maximum_height_percent) * room.size.y - 2), minimum_room_size.y, room.size.y - 1)
	
	var x_position = build_rng.randi_range(room.position.x, room.end.x - width)
	var y_position = build_rng.randi_range(room.position.y, room.end.y - height)
	
	return Rect2(Vector2(x_position, y_position), Vector2(width, height))
	
func make_hallways():
	var current_zone = zones[-1]
	if !current_zone.leaf:
		current_zone = current_zone.right
	while true:
		break

func connect_rooms(from_room, to_room):
	var start_pos = null
	var end_pos = null
	if from_room.position.y == to_room.position.y and from_room.end.y == to_room.end.y:
		var split_y = build_rng.randi_range(from_room.position.y + 1, from_room.end.y - 1)
		start_pos = Vector2(from_room.position.x + int(from_room.size.x/2), split_y )
		end_pos = Vector2(to_room.position.x + int(to_room.size.x/2), split_y)
	else:
		var split_x = build_rng.randi_range(from_room.position.x + 1, from_room.end.x - 1)
		start_pos = Vector2(split_x, from_room.position.y + int(from_room.size.y/2))
		end_pos = Vector2(split_x, to_room.position.y + int(to_room.size.y/2))
	dig_points(start_pos, end_pos)

func dig_points(start_pos, end_pos):
	if start_pos.x == end_pos.x:
		for i in range(min(start_pos.y, end_pos.y), max(start_pos.y, end_pos.y) ):
			set_cell(start_pos.x, i, 1)
	elif start_pos.y == end_pos.y:
		for i in range(min(start_pos.x, end_pos.x), max(start_pos.x, end_pos.x)):
			set_cell(i, start_pos.y, 1)

func uninspect_rooms(room_list):
	for i in range(room_list.size()):
		room_list[i]["traversed"] = false

func calc_node_depth(node):
	var i = 0
	while node:
		node = node["parent"]
		i += 1
	return i

func bsp_split(zone):
	var current_rect = zone.rect
	var lcr
	var left_child
	var rcr
	var right_child
	var new_rects
	if split_stop_chance and build_rng.randf() <= split_stop_chance:
		return false
	if current_rect.size.x <= minimum_zone_size.x and current_rect.size.y <= minimum_zone_size.y:
		return false
	if current_rect.size.x > maximum_zone_size.x and current_rect.size.y < maximum_zone_size.y:
		new_rects = split_rect_x(current_rect)
	elif current_rect.size.y > maximum_zone_size.y and current_rect.size.x < maximum_zone_size.y:
		new_rects = split_rect_y(current_rect)
	elif build_rng.randi() % 2:
		new_rects = split_rect_x(current_rect)
	else:
		new_rects = split_rect_y(current_rect)
	assert(new_rects.size() == 2)
	if new_rects[0].size.x < minimum_zone_size.x or new_rects[0].size.y < minimum_zone_size.x \
	  or new_rects[1].size.x < minimum_zone_size.x or new_rects[1].size.y < minimum_zone_size.y:
		return false
	zone.leaf = false
	lcr = new_rects[0]
	rcr = new_rects[1]
	left_child = MapZone.new(lcr)
	left_child.parent = zone
	right_child = MapZone.new(rcr)
	right_child.parent = zone
	zones.append(left_child)
	zones.append(right_child)
	zone.left = left_child
	zone.right = right_child
		
	
func find_nearest_pair(connected_rooms, unconnected_rooms):
	var lowest_distance = INF
	var from
	var to
	for croom in connected_rooms:
		for uroom in unconnected_rooms:
			var f_point = croom.position + (croom.size/2)
			var t_point = uroom.position + (uroom.size/2)
			var dist = f_point.distance_to(t_point)
			if dist < lowest_distance:
				lowest_distance = dist
				from = croom
				to = uroom
	return [from, to]
	
func split_rect_x(rect):
	var split_x = clamp(int(build_rng.randf_range(minimum_split_range, maximum_split_range) * rect.size.x),minimum_room_size.x, rect.size.x - minimum_room_size.x)
	var lcr = Rect2(rect.position, Vector2(split_x, rect.size.y))
	var rcr = Rect2(Vector2(rect.position.x + split_x, rect.position.y), Vector2(rect.size.x - split_x, rect.size.y))
	return [lcr, rcr]

func split_rect_y(rect):
	var split_y = clamp(int(build_rng.randf_range(minimum_split_range, maximum_split_range) * rect.size.y),minimum_room_size.y, rect.size.y - minimum_room_size.y)
	var lcr = Rect2(rect.position, Vector2(rect.size.x, split_y))
	var rcr = Rect2(Vector2(rect.position.x, rect.position.y + split_y), Vector2(rect.size.x, rect.size.y - split_y))
	return [lcr, rcr]
		
func fill_room(room, tile=TileType.Floor):
	for x in range(room.position.x, room.end.x):
		for y in range(room.position.y, room.end.y):
			set_cell(x,y,tile)
			
func wall_room(room, tile=TileType.Wall):
	for x in range(room.position.x, room.end.x):
		set_cell(x, room.position.y, tile)
		set_cell(x, room.end.y - 1, tile)
	for y in range(room.position.y + 1, room.end.y):
		set_cell(room.position.x, y, tile)
		set_cell(room.end.x - 1, y, tile)

func make_wall_v(room, x, tile=0):
	for y in range(room.position.y, room.end.y + 1):
		set_cell(x, y, tile)
		
func make_wall_h(room, y, tile=0):
	for x in range(room.position.x, room.end.x + 1):
		set_cell(x, y, tile)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_DebugGui_build_tree(tree):
	build_rect_tree_display(tree)


func shift_inspect_room(by):
	inspect_room += by
	if inspect_room >= rooms.size():
		inspect_room = inspect_room - rooms.size()
	elif inspect_room < 0:
		inspect_room = inspect_room.size() + inspect_room
	
