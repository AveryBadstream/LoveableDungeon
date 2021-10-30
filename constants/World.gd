extends Node

var GameWorld = null
var TMap = null
var world_dimensions = Vector2(0,0)
var is_ready = false
var rng

var object_types

enum GeneratorSignal {MapDimension, ActorList, ObjectList, TileList}
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const SIGHT_RANGE = 200

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func is_tile_walkable(at_cell):
	for thing in GameWorld.everything_at_cell(at_cell):
		if !thing.supports_action(ACT.DummyMove):
			return false
	return true

func can_see_player(actor):
	return FOV.can_see_point(actor.game_position, GameWorld.Player.game_position, GameWorld.fov_block_map, SIGHT_RANGE)

func _on_export_generator_config(config_type, config_value):
	if config_type == GeneratorSignal.MapDimension:
		world_dimensions = config_value
	elif config_type == GeneratorSignal.ObjectList:
		object_types = config_value

func get_action_targets_cell(action, at_cell:Vector2) -> Array:
	var targets = []
	var target_things = []
	if (action.target_type & ACT.TargetType.TargetAll) == ACT.TargetType.TargetAll:
		target_things = GameWorld.everything_at_cell(at_cell)
	if action.target_type & ACT.TargetType.TargetActor:
		target_things.append_array(GameWorld.actors_at_cell(at_cell))
	if action.target_type & ACT.TargetType.TargetObject:
		target_things.append_array(GameWorld.objects_at_cell(at_cell))
	if action.target_type & ACT.TargetType.TargetTile:
		target_things.append_array(GameWorld.tiles_at_cell(at_cell))
	if action.target_hints & ACT.TargetHint.WholeCellMustSupport:
		var all_things = GameWorld.everything_at_cell(at_cell, ~action.target_type)
		for thing in all_things:
			if !thing.supports_action(action):
				return []
	for thing in target_things:
		if thing.supports_action(action):
			targets.append(thing)
	return targets

func get_action_targets_area(action, at_cell:Vector2, area_radius:float=1) -> Dictionary:
	var action_area = []
	var origin_cell = action.get_origin_cell()
	var area_radius_int = ceil(area_radius)
	var targets = []
	for x in range(origin_cell.x - area_radius_int, origin_cell.x + area_radius_int + 1):
		for y in range(origin_cell.y - area_radius_int, origin_cell.y + area_radius_int + 1):
			var distance = Vector2(x, y).distance_to(action.get_origin_cell())
			if Vector2(x, y).distance_to(action.get_origin_cell()) <= area_radius:
				targets.append_array(get_action_targets_cell(action, Vector2(x,y)))
	return targets

func get_action_hint(at_cell):
	var highest_action_hint = 0
	for thing in GameWorld.everything_at_cell(at_cell):
		if thing.default_action > highest_action_hint:
			highest_action_hint = thing.default_action
	return highest_action_hint

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
