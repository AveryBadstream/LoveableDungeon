extends Node2D

signal action_complete(actor, target, action_type)
signal action_failed(actor, target, action_type)
signal action_impossible(actor, target, action_type)
signal world_ready()
signal message_0(msg)
signal log_2(msg, subject, object)

onready var TMap = $LoveableBasic
onready var LevelObjects = $LevelObjects
onready var LevelActors = $LevelActors
onready var Player = $LevelActors/Player
onready var FogOfWar = $FogOfWar
onready var Unexplored = $Unexplored
var LevelGenerator = load("res://map/Generators/basic_levelgen.tres")

var last_visiblilty_rect = Rect2(0,0,0,0)

const FOV = preload("res://constants/FOVRPAS.gd")
const Door = preload("res://objects/Door.tscn")
var fov_block_map
var pending_block_map_updates = []
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func build(build_rng):
	LevelGenerator.build_map(build_rng)

func try_move(actor, direction):
	if TMap.is_tile_walkable(actor.game_position.x, actor.game_position.y):
		return

# Called when the node enters the scene tree for the first time.
func _ready():
	.connect("message_0", MSG, "_on_message_0")
	.connect("log_2", MSG, "_on_log_2")
	LevelGenerator.connect("build_finished", TMap, "_on_build_finished")
	LevelGenerator.connect("place_door", self, "_on_place_door")
	LevelGenerator.connect("player_start_position", self, "_on_player_start_position")
	LevelGenerator.connect("export_generator_config", WRLD, "_on_export_generator_config")
	TMap.connect("tiles_ready", self, "_on_tiles_ready")
	EVNT.subscribe("update_object_vision_block", self, "_on_update_object_vision_block")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

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
	if !target_thing or ((action == ACT.Type.Move or (action == ACT.Type.None and target_thing.default_action == ACT.Type.Move)) and target_thing.is_walkable):
		if (action == ACT.Type.Move or action == ACT.Type.None) and TMap.is_tile_walkable(target_position):
			actor.game_position = target_position # Replace with function body.
			emit_signal("action_complete", actor, null, ACT.Type.Move)
			return
		else:
			emit_signal("action_failed", actor, null, ACT.Type.Move)
			return
	else:
		emit_signal("action_failed", actor, null, null)
	actor_do_action_to(actor, target_thing.default_action if action == ACT.Type.None else action, target_thing)

func _on_update_object_vision_block(actor, old_pos, new_pos, should_block):
	var should_update_fov = false
	if fov_block_map:
		if old_pos and should_block:
			fov_block_map[old_pos.x][old_pos.y] = 0
			should_update_fov = last_visiblilty_rect.has_point(old_pos)
		fov_block_map[new_pos.x][new_pos.y] = 1 if should_block else 0
		if should_update_fov or last_visiblilty_rect.has_point(new_pos):
			update_fov(Player.game_position)
	else:
		pending_block_map_updates.append([actor, old_pos, new_pos, should_block])

func _on_place_door(position):
	var new_door = Door.instance()
	new_door.game_position = position
	LevelObjects.add_child(new_door)
	pending_block_map_updates.append([new_door, null, new_door.game_position, true])

func object_at_position(position):
	for object in LevelObjects.get_children():
		if object.game_position == position:
			return object
	return null

func actor_at_position(position):
	for actor in LevelActors.get_children():
		if actor.game_position == position:
			return actor
	return null

func thing_at_position(position, prefer_actor=true):
	var found_actor = actor_at_position(position)
	if prefer_actor and found_actor:
		return found_actor
	var found_object = object_at_position(position)
	return found_object if found_object else found_actor
	
func _on_player_start_position(start_pos):
	Player.game_position = start_pos # Replace with function body.
	
func _on_tiles_ready(fov_block_tiles):
	fov_block_map = fov_block_tiles
	for x in range(WRLD.world_dimensions.x):
		for y in range(WRLD.world_dimensions.y):
			FogOfWar.set_cell(x, y, 0)
			Unexplored.set_cell(x, y, 0)
	for block_map_update in pending_block_map_updates:
		_on_update_object_vision_block(block_map_update[0], block_map_update[1], block_map_update[2], block_map_update[3])
	pending_block_map_updates = []
	emit_signal("world_ready")
	
func update_fov(from_position):
	var min_x = INF
	var min_y = INF
	var max_x = 0
	var max_y = 0
	for x in range(WRLD.world_dimensions.x):
		for y in range(WRLD.world_dimensions.y):
			FogOfWar.set_cell(x, y, 0)
	var cells = FOV.calc_visible_cells_from(from_position.x, from_position.y, WRLD.SIGHT_RANGE, fov_block_map)
	for cell in cells:
		min_x = min(cell.x, min_x)
		min_y = min(cell.y, min_y)
		max_x = max(cell.x, max_x)
		max_y = max(cell.y, max_y)
		FogOfWar.set_cellv(cell, -1)
		Unexplored.set_cellv(cell, -1)
	last_visiblilty_rect.position = Vector2(min_x, min_y)
	last_visiblilty_rect.end = Vector2(max_x + 1, max_y + 1)
