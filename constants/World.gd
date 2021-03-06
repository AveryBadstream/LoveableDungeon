extends Node

const default_size = Vector2(1280, 720)

var GameWorld = null
var TMap = null
var world_dimensions = Vector2(0,0)
var is_ready = false
var tween
var tween_stash
var rng
var path_map: AStar2D

var cell_interaction_mask_map = []
var cell_occupancy_map = []

var tweens = []
var free_tweens = []

var object_types
var actor_types

var canvas_layer:CanvasLayer

enum GeneratorSignal {MapDimension, ActorList, ObjectList, TileList}
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
const SIGHT_RANGE = 80

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_game_world(new_game_world):
	GameWorld = new_game_world
	cell_interaction_mask_map = GameWorld.cell_interaction_mask_map
	cell_occupancy_map = GameWorld.cell_occupancy_map

func is_tile_walkable(at_cell):
	return ~(cell_occupancy_map[at_cell.x][at_cell.y] & TIL.CellInteractions.BlocksWalk)

func can_see_player(actor):
	if GameWorld.last_visiblilty_rect.has_point(actor.game_position):
		return FOV.can_see_point(actor.game_position, GameWorld.Player.game_position, SIGHT_RANGE)
	return false

func path_to_player(actor):
	return path_to_point(actor, GameWorld.Player.game_position)

func path_to_point(actor, point):
	var start = path_map.get_closest_point(actor.game_position)
	var finish = path_map.get_closest_point(point)
	return path_map.get_point_path(start, finish)

func _on_export_generator_config(config_type, config_value):
	if config_type == GeneratorSignal.MapDimension:
		world_dimensions = config_value
	elif config_type == GeneratorSignal.ObjectList:
		object_types = config_value
	elif config_type == GeneratorSignal.ActorList:
		actor_types = config_value

func get_player_position():
	return GameWorld.Player.game_position

func get_action_targets_cell(action, at_cell:Vector2) -> Array:
	var targets = []
	var target_things = []
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

func get_action_targets_area(action, at_cell:Vector2, area_radius:float=1) -> Array:
	var action_area = []
	var origin_cell = action.get_origin_cell()
	var area_radius_int = ceil(area_radius)
	var targets = []
	for x in range(origin_cell.x - area_radius_int, origin_cell.x + area_radius_int + 1):
		for y in range(origin_cell.y - area_radius_int, origin_cell.y + area_radius_int + 1):
			if Vector2(x, y).distance_to(action.get_origin_cell()) <= area_radius:
				targets.append_array(get_action_targets_cell(action, Vector2(x,y)))
	return targets

func get_cone_action_cells(action, at_cell:Vector2) -> Array:
	return FOV.cast_psuedo_cone(action.get_origin_cell(), at_cell, action.action_area, action.action_range, TIL.CellInteractions.Occupies)

func get_action_targets_cone(action, at_cell:Vector2) -> Array:
	var targets = []
	for cell in FOV.cast_psuedo_cone(action.action_actor.game_position, at_cell, action.action_area, action.action_range, GameWorld.fov_block_map):
		targets.append_array(get_action_targets_cell(action, cell))
	return targets

func get_action_hint(at_cell):
	var highest_action_hint = 0
	for thing in cell_occupancy_map[at_cell.x][at_cell.y]:
		if thing.default_action > highest_action_hint:
			highest_action_hint = thing.default_action
	return highest_action_hint

func get_action_hints(at_cell):
	var all_hints = []
	if at_cell.x < 0 or at_cell.y < 0 or at_cell.x >= world_dimensions.x or at_cell.y >= world_dimensions.y:
		return []
	for thing in cell_occupancy_map[at_cell.x][at_cell.y]:
			var thing_default_action = thing.default_action
			if thing_default_action > ACT.Type.None:
				all_hints.append(thing_default_action)
	all_hints.sort()
	all_hints.invert()
	return all_hints
	
func get_mouse_game_position():
	if not is_ready:
		return false
	return TMap.world_to_map(TMap.get_viewport().canvas_transform.inverse().xform(get_viewport().get_mouse_position()))

func cell_is_visible(at_cell):
	if is_ready:
		if GameWorld.last_visiblilty_rect.has_point(at_cell):
			for cell in GameWorld.last_visible_set:
				if cell == at_cell:
					return true
	return false

func cell_occupied(at_cell):
	var target_cim = cell_interaction_mask_map[at_cell.x][at_cell.y]
	return target_cim & TIL.CellInteractions.Occupies

func get_targets_at_by_mask(at_cell, target_mask):
	var found_targets = []
	for target in cell_occupancy_map[at_cell.x][at_cell.y]:
		if target.thing_type & target_mask:
			found_targets.append(target)
	return found_targets

func get_cell_occupier(at_cell):
	for target in cell_occupancy_map[at_cell.x][at_cell.y]:
		if target.cell_interaction_mask & TIL.CellInteractions.Occupies:
			return target
	return null
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
