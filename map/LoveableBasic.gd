extends TileMap


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export(Array, TIL.Type) var tile_type_map

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

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

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
