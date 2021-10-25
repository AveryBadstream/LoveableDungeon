extends TileMap

signal tiles_ready()


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(Array, TIL.Type) var tile_type_map

var dimensions

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _on_export_generator_config(signal_type, value):
	if signal_type == WRLD.GeneratorSignal.MapDimension:
		dimensions = value

func _on_build_finished(tiles):
	for x in range(tiles.size()):
		for y in range(tiles[x].size()):
			var tile_type = tiles[x][y]
			set_tile(x, y, tile_type)
	update_bitmask_region(Vector2(0,0), Vector2(tiles.size(), tiles[0].size()))
	emit_signal("tiles_ready")

func set_tilev(pos: Vector2, tile_type: int):
	var tile_i = tile_type_map.find(tile_type)
	if tile_i == - 1:
		return
	set_cellv(pos, tile_i)

func set_tile(x: int, y: int, tile_type: int):
	var tile_i = tile_type_map.find(tile_type)
	if tile_i == - 1:
		return
	set_cell(x, y, tile_i)

func get_tilev(pos: Vector2):
	return tile_type_map[get_cellv(pos)]
	
func get_tile(x: int, y: int):
	return tile_type_map[get_cell(x, y)]
	
func is_tile_walkable(target_position: Vector2):
	return TIL.TILE_WALKABLE[get_tilev(target_position)]

func is_tile_flyable(target_position: Vector2):
	return TIL.TILE_FLYABLE[get_tilev(target_position)]
	
func is_tile_phaseable(target_position: Vector2):
	return TIL.TILE_PHASEABLE[get_tilev(target_position)]

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
