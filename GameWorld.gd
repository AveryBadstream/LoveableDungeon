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

const FOV = preload("res://constants/FOVRPAS.gd")
const Door = preload("res://objects/Door.tscn")
var fov_block_map
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

func _on_place_door(position):
	var new_door = Door.instance()
	new_door.game_position = position
	LevelObjects.add_child(new_door)

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
	emit_signal("world_ready")
	
func update_fov(from_position):
	for x in range(WRLD.world_dimensions.x):
		for y in range(WRLD.world_dimensions.y):
			FogOfWar.set_cell(x, y, 0)
	var cells = FOV.calc_visible_cells_from(from_position.x, from_position.y, WRLD.SIGHT_RANGE, fov_block_map)
	for cell in cells:
		FogOfWar.set_cellv(cell, -1)
		Unexplored.set_cellv(cell, -1)
