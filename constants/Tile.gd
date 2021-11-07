tool
extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum Type {Floor, Wall, Ground, Rock, None, Ice}

const TILE_WALKABLE = [1,0,1,0,0,1]
const TILE_FLYABLE = [1,0,1,0,0,1]
const TILE_PHASEABLE = [1,1,1,0,0,1]
const TILE_BLOCK_FOV = [0,1,0,1,1,0]

var utiles = {}

const IceTile = preload("res://map/Ice.gd")

enum CellInteractions {None = 0, BlocksFOV = 1, Walkable = 2, Flyable = 4, Phaseable = 8, Occupies = 16, PlayerRemembers = 32, Immovable = 64}

# Called when the node enters the scene tree for the first time.
func _ready():
	utiles[Type.Floor] = UTile.new("Floor", true, true, true, false, false)
	utiles[Type.Wall] = UTile.new("Wall", false, false, true, true, true)
	utiles[Type.Ground] = UTile.new("Ground", true, true, true, false, false)
	utiles[Type.Rock] = UTile.new("Rock", false, false, false, true, true)
	utiles[Type.None] = UTile.new("NONE", false, false, false, true, true)
	utiles[Type.Ice] = IceTile.new("Ice", true, true, true, false, false)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func is_line_obstructed(from, to, tiles) -> bool:
	var dx = abs(to.x - from.x)
	var sx = 1 if from.x < to.x else -1
	var dy = -abs(to.y - from.y)
	var sy = 1 if from.y < to.y else -1
	var err = dx+dy
	var e2
	var walker = Vector2(from.x, from.y)
	var max_x = tiles.size()
	var max_y = tiles[0].size()
	
	while walker != to:
		if walker.x > max_x or walker.y > max_y or tiles[walker.x][walker.y]:
			return true
			e2 = 2*err
			if e2 >= dy:
				err += dy
				walker.x += sx
			if e2 <= dx:
				err += dx
				walker.x += sy
	return false
	
func interpolated_line(p0, p1):
	var points = PoolVector2Array()
	var dx = p1.x - p0.x
	var dy = p1.y - p0.y
	var N = max(abs(dx), abs(dy))
	for i in N + 1:
		var t = float(i) / float(N)
		var point = Vector2(round(lerp(p0.x, p1.x, t)), round(lerp(p0.y, p1.y, t)))
		points.append(point)
	return points

func get_bres_line(from, to, check_tilemap = null) -> Array:
	var dx = abs(to.x - from.x)
	var sx = 1 if from.x < to.x else -1
	var dy = -abs(to.y - from.y)
	var sy = 1 if from.y < to.y else -1
	var err = dx+dy
	var e2
	var walker = Vector2(from.x, from.y)
	var tiles_in_line = [Vector2(from.x, from.y)]
	var max_x
	var max_y
	if check_tilemap:
		max_x = check_tilemap.size()
		max_y = check_tilemap[0].size()
	
	while walker != to:
			e2 = 2*err
			if e2 >= dy:
				err += dy
				walker.x += sx
			if e2 <= dx:
				err += dx
				walker.y += sy
			if check_tilemap and (walker.x < 0 or walker.y < 0 or walker.x > max_x or walker.y > max_y or check_tilemap[walker.x][walker.y]):
				break
			tiles_in_line.append(Vector2(int(walker.x), int(walker.y)))
	return tiles_in_line
