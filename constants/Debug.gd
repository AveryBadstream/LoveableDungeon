extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var TileHighlight

var HighlightGroup

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func clear_highlight():
	for child in HighlightGroup.get_children():
		HighlightGroup.remove_child(child)
		child.queue_free()

func highlight_octant(from, to):
	var oct = FOV.get_octant(from, to)
	for cell in FOV._visible_cells_in_octant_from(from.x, from.y, oct, WRLD.SIGHT_RANGE, WRLD.GameWorld.fov_block_map):
		highlight_cell(cell)

func highlight_fov(from):
	var full_fov = FOV.calc_visible_cells_from(from.x, from.y, WRLD.SIGHT_RANGE, WRLD.GameWorld.fov_block_map)
	for cell in full_fov:
		highlight_cell(cell)

func highlight_cell(cell:Vector2):
	var new_highlight = TileHighlight.duplicate()
	new_highlight.rect_position = cell * 16
	HighlightGroup.add_child(new_highlight)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
