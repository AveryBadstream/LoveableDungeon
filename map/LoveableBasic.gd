extends TileMap

signal tiles_ready()


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

#Mapping between TIL.Type and actual tile indexes
export(Array, TIL.Type) var tile_type_map
var tile_object_map = {}

var dimensions
var visibility_blocking_tiles

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_export_generator_config(signal_type, value):
	if signal_type == WRLD.GeneratorSignal.MapDimension:
		dimensions = value

func _on_build_finished(tiles):
	var fov_block_tiles = []
	for x in range(tiles.size()):
		fov_block_tiles.append([])
		for y in range(tiles[x].size()):
			var tile_type = tiles[x][y]
			set_tile(x, y, tile_type)
	update_bitmask_region(Vector2(0,0), Vector2(tiles.size(), tiles[0].size()))
	emit_signal("tiles_ready")

func set_tilev(pos: Vector2, tile_type: int):
	var tile_i = - 1
	if tile_type == - 1:
		tile_i = tile_type
	else:
		tile_i = tile_type_map.find(tile_type)
	set_cellv(pos, tile_i)

func set_tile(x: int, y: int, tile_type: int):
	var tile_i = -1
	if tile_type == -1:
		tile_i = tile_type
	else:
		tile_i = tile_type_map.find(tile_type)
	set_cell(x, y, tile_i)

func get_tilev(pos: Vector2):
	var tile_i = get_cellv(pos)
	if tile_i == -1:
		return tile_i
	return tile_type_map[get_cellv(pos)]
	
func can_tile_support_action(target_position: Vector2, action):
	if action.action_type == ACT.Type.Move and is_tile_walkable(target_position):
		return true
	else:
		return false

func get_tile_objv(at_cell: Vector2):
	var tile_i = get_cellv(at_cell)
	return make_tile_obj(at_cell, tile_i)

func make_tile_obj(at_cell: Vector2, tile_i:int):
	var tile_type = tile_type_map[tile_i]
	if self.tile_object_map.has(tile_i):
		pass
	else:
		return ITile.new(TIL.utiles[tile_type],at_cell)

func get_tile(x: int, y: int):
	var tile_i = get_cell(x, y)
	if tile_i == -1:
		return tile_i
	return tile_type_map[get_cell(x, y)]

func get_utile(x:int, y:int):
	return TIL.utiles[tile_type_map[get_cell(x, y)]]
	
func is_tile_walkable(target_position: Vector2):
	return TIL.TILE_WALKABLE[get_tilev(target_position)]

func is_tile_flyable(target_position: Vector2):
	return TIL.TILE_FLYABLE[get_tilev(target_position)]
	
func is_tile_phaseable(target_position: Vector2):
	return TIL.TILE_PHASEABLE[get_tilev(target_position)]


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
