extends Node2D

signal action_complete(actor, target, action_type)
signal action_failed(actor, target, action_type)
signal action_impossible(actor, target, action_type)
signal world_ready()
signal message_0(msg)
signal log_2(msg, subject, object)


#onready var LevelObjects = $LevelObjects
onready var LevelObjects = $WorldView/LevelObjects
#onready var LevelActors = $LevelActors
onready var LevelActors = $WorldView/LevelActors
var Player: Sprite
#onready var FOWGhosts = $FOWGhosts
onready var FOWGhosts = $ShadowWorldView/FOWGhosts
onready var WorldView = $WorldView
onready var WorldCamera = $WorldView/FakePlayer/WorldCamera

onready var WorldTiles = $WorldView/WorldTiles
onready var ShadowWorldTiles = $ShadowWorldView/ShadowWorldTiles
onready var MaskTiles = $MaskWorld/MaskTiles

var LevelGenerator = load("res://map/Generators/basic_levelgen.tres")

var last_visiblilty_rect = Rect2(0,0,0,0)
var last_visible_set = []

var tile_type_map = [TIL.Type.Wall, TIL.Type.Floor,TIL.Type.Ground, TIL.Type.None, TIL.Type.Rock, TIL.Type.None, TIL.Type.Ice]

var walk_pathf = AStar2D.new()
var fly_pathf = AStar2D.new()
var phase_pathf = AStar2D.new()

var world_gen_timer
var queued_things = []
var queued_connections = []
var queued_removals = []
var recently_moved = {}

const Door = preload("res://objects/Door.tscn")
var cell_interaction_mask_map = []
var cell_occupancy_map = []
var pending_cimmap_updates = []
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func build(build_rng):
	world_gen_timer = OS.get_system_time_msecs()
	LevelGenerator.build_map(build_rng)

# Called when the node enters the scene tree for the first time.
func _ready():
	EVNT.subscribe("export_generator_config", WRLD, "_on_export_generator_config")
	EVNT.subscribe("player_start_position", self, "_on_player_start_position")
	EVNT.subscribe("place_thing", self, "_on_place_thing")
	EVNT.subscribe("remove_thing", self, "_on_remove_thing")
	EVNT.subscribe("connect_things", self, "_on_connect_things")
	LevelGenerator.connect("build_finished", self, "_on_build_finished")
	LevelGenerator.connect("place_door", self, "_on_place_door")
	LevelGenerator.connect("player_start_position", self, "_on_player_start_position")
	LevelGenerator.connect("export_generator_config", WRLD, "_on_export_generator_config")
	EVNT.subscribe("create_ghost", self, "_on_create_ghost")
	EVNT.subscribe("end_ghost", self, "_on_end_ghost")
	EVNT.subscribe("update_fov", self, "_on_update_fov")
	EVNT.subscribe("object_moved", self, "_on_object_moved")
	EVNT.subscribe("try_action_at", self, "_on_actor_try_action_at")
	EVNT.subscribe("update_cimmap", self, "_on_update_cimmap")
	EVNT.subscribe("slammed", self, "_on_slammed")

func _on_build_finished(tiles):
	var fov_block_tiles = []
	for x in range(tiles.size()):
		cell_interaction_mask_map.append([])
		cell_occupancy_map.append([])
		for y in range(tiles[x].size()):
			var tile_type = tiles[x][y]
			var til_i = tile_type_map.find(tile_type)
#			if til_i == 4:
#				til_i = 1
			if x == 0 or x == tiles.size()-1 or y == 0 or y == tiles[x].size()-1:
				if til_i != 0:
					til_i = 4
			var utile = TIL.utiles[tile_type_map[til_i]]
			cell_occupancy_map[x].append([ITile.new(utile, Vector2(x,y))])
			cell_interaction_mask_map[x].append(utile.cell_interaction_mask)
			WorldTiles.set_cell(x,y,til_i)
			ShadowWorldTiles.set_cell(x,y,til_i)
	WorldTiles.update_bitmask_region(Vector2(0,0), Vector2(tiles.size(), tiles[0].size()))
	ShadowWorldTiles.update_bitmask_region(Vector2(0,0), Vector2(tiles.size(), tiles[0].size()))
	var ShadowTransform = RemoteTransform2D.new()
	Player.add_child(ShadowTransform)
	ShadowTransform.remote_path = "../../../../ShadowWorldView/FakePlayer"
	var MaskTransform = RemoteTransform2D.new()
	Player.add_child(MaskTransform)
	MaskTransform.remote_path = "../../../../MaskWorld/FakePlayer"
	var WorldTransform = RemoteTransform2D.new()
	Player.add_child(WorldTransform)
	WorldTransform.remote_path = "../../../FakePlayer"
	var OverlayTransform = RemoteTransform2D.new()
	Player.add_child(OverlayTransform)
	OverlayTransform.remote_path = "../../../../OverlayWorld/FakePlayer"
	rebuild_pathfinding(walk_pathf, TIL.CellInteractions.BlocksWalk)
	WRLD.path_map = walk_pathf
	var total_time = OS.get_system_time_msecs() - world_gen_timer
	process_add_queue()
	process_remove_queue()
	print("Worldgen Took: " + str(total_time))
	EVNT.emit_signal("world_ready")
	process_add_queue()
	process_remove_queue()
	process_connection_queue()
	process_cimmap_updates()
	EVNT.emit_signal("player_ready", Player)

func _on_object_moved(thing, from_cell, to_cell):
	move_in_maps(thing, from_cell, to_cell)
	for triggered_thing in cell_occupancy_map[to_cell.x][to_cell.y]:
		EVNT.trigger_MovedTo(thing, triggered_thing, from_cell, to_cell )
	if !recently_moved.keys().has(thing.name):
		recently_moved[thing.name] = []
	recently_moved[thing.name].append([thing, from_cell, to_cell])
	if thing.is_player:
		EVNT.emit_signal("update_fov")
		EVNT.emit_signal("player_position", Player.global_position)

func _on_slammed(thing, into, from, to):
	EVNT.trigger_SlammedInto(into, thing, from, to)

func step_end():
	for move_records in recently_moved.values():
		var move_record = move_records[-1]
		var thing = move_record[0]
		var from_cell = move_record[1]
		var to_cell = move_record[2]
		for triggered_thing in cell_occupancy_map[to_cell.x][to_cell.y]:
			EVNT.trigger_EndedMovement(thing, triggered_thing, from_cell, to_cell)
	recently_moved = {}
		

func move_in_maps(thing, from_cell, to_cell):
	cell_occupancy_map[from_cell.x][from_cell.y].erase(thing)
	cell_occupancy_map[to_cell.x][to_cell.y].append(thing)
	update_cim(from_cell)
	update_cim(to_cell)

func actor_do_action_to(actor, action, subject):
	if !actor.actions_available.has(action):
		emit_signal("action_impossible", actor, subject, action)
		return
	elif !subject.can_actor_do_action(actor, action):
		emit_signal("action_failed", actor, subject, action)
		return
	else:
		subject.actor_do_action(actor, action)
		emit_signal("action_complete", actor, subject, action)
		return

func _on_actor_try_action_at(actor, target_position, action = null):
	var target_thing = thing_at_position(target_position)
	if target_thing and target_thing.default_action == ACT.Type.None:
		emit_signal("action_impossible")
		return
	if !target_thing or ((action == ACT.Type.Move or (action == ACT.Type.None and target_thing.default_action == ACT.Type.Move)) and target_thing.is_walkable):
#		if (action == ACT.Type.Move or action == ACT.Type.None) and TMap.is_tile_walkable(target_position):
#			actor.game_position = target_position # Replace with function body.
#			emit_signal("action_complete", actor, null, ACT.Type.Move)
#			return
#		else:
		emit_signal("action_failed", actor, null, ACT.Type.Move)
		return
	else:
		emit_signal("action_failed", actor, null, null)
	actor_do_action_to(actor, target_thing.default_action if action == ACT.Type.None else action, target_thing)

func _on_create_ghost(ghost):
	FOWGhosts.add_child(ghost)

func _on_end_ghost(ghost):
	FOWGhosts.remove_child(ghost)
	ghost.queue_free()
	
func _on_place_thing(thing_type, thing_index, at_cell):
	if WRLD.is_ready:
		add_thing(thing_type, thing_index, at_cell)
	else:
		queued_things.append([thing_type, thing_index, at_cell])

func add_thing(thing_type, thing_index, at_cell):
	var new_thing
	if thing_type == ACT.TargetType.TargetObject:
		new_thing = WRLD.object_types[thing_index].instance()
		new_thing.set_initial_game_position(at_cell)
		add_to_maps(new_thing)
		LevelObjects.add_child(new_thing)
	elif thing_type == ACT.TargetType.TargetActor:
		new_thing = WRLD.actor_types[thing_index].instance()
		new_thing.set_initial_game_position(at_cell)
		add_to_maps(new_thing)
		LevelActors.add_child(new_thing)
		new_thing.own_fucking_actions()

func add_to_maps(thing):
	var at_cell = thing.game_position
	cell_occupancy_map[at_cell.x][at_cell.y].append(thing)
	update_cim(at_cell)

func _on_connect_things(from_thing_type, from_thing_index, from_thing_cell, to_thing_type, to_thing_index, to_thing_cell):
	if WRLD.is_ready:
		connect_things(from_thing_type, from_thing_index, from_thing_cell, to_thing_type, to_thing_index, to_thing_cell)
	else:
		queued_connections.append([from_thing_type, from_thing_index, from_thing_cell, to_thing_type, to_thing_index, to_thing_cell])

func connect_things(from_thing_type, from_thing_index, from_thing_cell, to_thing_type, to_thing_index, to_thing_cell):
	var from_thing = find_thing_by_type_index_cell(from_thing_type, from_thing_index, from_thing_cell)
	var to_thing = find_thing_by_type_index_cell(to_thing_type, to_thing_index, to_thing_cell)
	if not from_thing or not to_thing:
		return
	from_thing.connect_to(to_thing)

func _on_remove_thing(thing_type, thing_index, at_cell):
	if WRLD.is_ready:
		remove_thing(thing_type, thing_index, at_cell)
	else:
		queued_removals.append([thing_type, thing_index, at_cell])
	

func remove_thing(thing_type, thing_index, at_cell):
	var should_rebuild_fov = false
	var found_thing = find_thing_by_type_index_cell(thing_type, thing_index, at_cell)
	if not found_thing:
		return
	match thing_type:
		ACT.TargetType.TargetObject:
			remove_object(found_thing)
			
func remove_object(object_to_remove):
	remove_from_maps(object_to_remove)
	LevelObjects.remove_child(object_to_remove)
	object_to_remove.queue_free()

func remove_from_maps(thing):
	var at_cell = thing.game_position
	cell_occupancy_map[at_cell.x][at_cell.y].erase(thing)
	update_cim(at_cell)

func remove_from_cim(thing, at_cell):
	var blocked_vision = thing.cell_interaction_mask & TIL.CellInteractions.BlocksFOV
	var new_mask = 0
	for thing in cell_occupancy_map[at_cell.x][at_cell.y]:
		new_mask |= thing.cell_interaction_mask
	if blocked_vision and new_mask & TIL.CellInteractions.BlocksFOV:
		EVNT.emit_signal("update_fov")

func _on_update_cimmap(at_cell):
	if WRLD.is_ready:
		update_cim(at_cell)

func update_cim(at_cell):
	var new_cim = 0
	var old_cim = cell_interaction_mask_map[at_cell.x][at_cell.y]
	for thing in cell_occupancy_map[at_cell.x][at_cell.y]:
		new_cim |= thing.cell_interaction_mask
	cell_interaction_mask_map[at_cell.x][at_cell.y] = new_cim
	if old_cim & TIL.CellInteractions.BlocksFOV != new_cim & TIL.CellInteractions.BlocksFOV:
		EVNT.emit_signal("update_fov")
	walk_pathf.set_point_disabled(walk_pathf.get_closest_point(at_cell), new_cim & TIL.CellInteractions.BlocksWalk)

func find_thing_by_type_index_cell(thing_type, thing_index, at_cell):
	for thing in everything_at_cell(at_cell, thing_type):
		if thing.get_filename() == WRLD.object_types[thing_index].get_path():
			return thing
	return null

func object_at_cell(at_cell: Vector2):
	for object in LevelObjects.get_children():
		if object.game_position == at_cell:
			return object
	return null

func actor_at_cell(at_cell: Vector2):
	for actor in LevelActors.get_children():
		if actor.game_position == position:
			return actor
	return null

func objects_at_cell(at_cell: Vector2) -> Array:
	var found = []
	for object in LevelObjects.get_children():
		if object.game_position == at_cell:
			found.append(object)
	return found

func actors_at_cell(at_cell: Vector2) -> Array:
	var found = []
	for actor in LevelActors.get_children():
		if actor.game_position == at_cell:
			found.append(actor)
	return found

func tiles_at_cell(at_cell: Vector2) -> Array:
	return everything_at_cell(at_cell, ACT.TargetType.TargetTile)

func everything_at_cell(at_cell: Vector2, target_mask:int = ~0):
	var everything = []
	for thing in cell_occupancy_map[at_cell.x][at_cell.y]:
		if thing.thing_type & target_mask:
			everything.append(thing)
	return everything

func thing_at_position(position, prefer_actor=true):
	var found_actor = actor_at_cell(position)
	if prefer_actor and found_actor:
		return found_actor
	var found_object = object_at_cell(position)
	return found_object if found_object else found_actor
	
func _on_player_start_position(start_pos):
	LevelActors.add_child(Player)
	Player.set_initial_game_position(start_pos)
	EVNT.emit_signal("player_position", Player.global_position)
	

func rebuild_pathfinding(astar: AStar2D, block_mask):
	var point_map = []
	for x in range(WRLD.world_dimensions.x):
		point_map.append([])
		for y in range(WRLD.world_dimensions.y):
			var new_point_id = astar.get_available_point_id()
			astar.add_point(new_point_id, Vector2(x,y))
			point_map[x].append(new_point_id)
	for x in range(WRLD.world_dimensions.x):
		for y in range(WRLD.world_dimensions.y):
			var cur_p = point_map[x][y]
			if y > 0:
				if ~(cell_interaction_mask_map[x][y-1] & block_mask):
					astar.connect_points(cur_p, point_map[x][y-1])
			if x > 0:
				if ~(cell_interaction_mask_map[x-1][y] & block_mask):
					astar.connect_points(cur_p, point_map[x-1][y])
			if x >0 and y > 0:
				if ~(cell_interaction_mask_map[x-1][y-1] & block_mask):
					astar.connect_points(cur_p, point_map[x-1][y-1])
			if x > 0 and y+1 < WRLD.world_dimensions.y:
				if ~(cell_interaction_mask_map[x-1][y+1] & block_mask):
					astar.connect_points(cur_p, point_map[x-1][y+1])

func process_cimmap_updates():
	for thing in pending_cimmap_updates:
		update_cim(thing.game_position)

func process_add_queue():
	var old_queue = queued_things
	queued_things = []
	for thing in old_queue:
		add_thing(thing[0], thing[1], thing[2])

func process_connection_queue():
	var old_queue = queued_connections
	queued_connections = []
	for connection in old_queue:
		connect_things(connection[0], connection[1], connection[2], connection[3], connection[4], connection[5])

func process_remove_queue():
	var old_queue = queued_removals
	queued_removals = []
	for thing in old_queue:
		remove_thing(thing[0], thing[1], thing[2])

func _on_update_fov():
	update_fov_by_location(Player.game_position)

func update_fov_by_location(from_cell, hide_old_fov = true):
	if !WRLD.is_ready:
		return
	var time_before = OS.get_system_time_msecs()
	var min_x = INF
	var min_y = INF
	var max_x = 0
	var max_y = 0
	if hide_old_fov:
		for cell in last_visible_set:
			hide_cell(cell)
	var cells = FOV.cast_area(from_cell, WRLD.SIGHT_RANGE, TIL.CellInteractions.BlocksFOV)
	for cell in cells:
		min_x = min(cell.x, min_x)
		min_y = min(cell.y, min_y)
		max_x = max(cell.x, max_x)
		max_y = max(cell.y, max_y)
		show_cell(cell)
	last_visiblilty_rect.position = Vector2(min_x, min_y)
	last_visiblilty_rect.end = Vector2(max_x + 1, max_y + 1)
	last_visible_set = cells
	var total_time = OS.get_system_time_msecs() - time_before
	print("Fov took: " + str(total_time) + "ms")

func hide_cell(at_cell):
	for occupant in cell_occupancy_map[at_cell.x][at_cell.y]:
		occupant.hide()
	MaskTiles.set_cellv(at_cell, 0)

func show_cell(at_cell):
	for occupant in cell_occupancy_map[at_cell.x][at_cell.y]:
		occupant.show()
	MaskTiles.set_cellv(at_cell, 1)
