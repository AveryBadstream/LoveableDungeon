extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var area_hint_indicator = preload("res://ui/AreaHintRect.tscn")
onready var angle_line = $Line2D

onready var area_highlight = $AreaHighlight

var hint_area_type = ACT.TargetArea.TargetNone
var hint_area_args = []
var last_mouse_game_position = Vector2.ZERO
var last_octant = null
# Called when the node enters the scene tree for the first time.
func _ready():
	EVNT.subscribe("hint_area_cone", self, "_on_hint_area_cone")# Replace with function body.

func _on_hint_area_cone(from, radius, width):
	var mouse_pos = WRLD.get_mouse_game_position()
	hint_area_args = [from, radius, width]
	hint_area_type = ACT.TargetArea.TargetCone
	hint_cone_update(mouse_pos)

func update_hint_area(mouse_pos):
	if hint_area_type == ACT.TargetArea.TargetNone:
		return
	elif hint_area_type == ACT.TargetArea.TargetCone:
		hint_cone_update(mouse_pos)

func hint_cone_update(mouse_pos):
	last_mouse_game_position = mouse_pos
	var oct = FOV._get_octant(hint_area_args[0], mouse_pos)
#	var cells = FOV._visible_cells_in_octant_from(hint_area_args[0], oct, 200, WRLD.GameWorld.fov_block_map)
	for hint in area_highlight.get_children():
		area_highlight.remove_child(hint)
		hint.queue_free()
	angle_line.clear_points()
	var from = hint_area_args[0]
	var offset = Vector2(8,8)
#	if delta.x < 0 and delta.y == 0:
#		from = from + Vector2(0, 0.5)
	#mouse_pos += Vector2(0.5, 0.5)
	var angle_v = from.direction_to(mouse_pos) * hint_area_args[1]
	var min_v = angle_v.rotated(-(hint_area_args[2]/2))
	var max_v = angle_v.rotated(hint_area_args[2]/2)
	angle_line.add_point(from * 16 + offset)
	angle_line.add_point((min_v + from) * 16 + offset)
	angle_line.add_point((angle_v+from) * 16 + offset)
	angle_line.add_point((max_v + from) * 16 + offset)
	angle_line.add_point(from * 16 + offset)
	angle_line.add_point((angle_v+from) * 16 + offset)

	var cells = FOV.cast_cone_at_corrected(from, mouse_pos, hint_area_args[2], hint_area_args[1], WRLD.GameWorld.fov_block_map)
	cells.sort()
	for cell in cells:
		var new_hint:ColorRect = area_hint_indicator.instance()
		new_hint.rect_position = cell * 16
		area_highlight.add_child(new_hint)

func _input(event):
	if !event.is_pressed():
		return
	if event.is_action("wheel_up"):
		hint_area_args[2] += deg2rad(5)
		update_hint_area(WRLD.get_mouse_game_position())
	elif event.is_action("wheel_down"):
		hint_area_args[2] -= deg2rad(5)
		update_hint_area(WRLD.get_mouse_game_position())
	elif event is InputEventMouseButton:
			hint_area_type = ACT.TargetArea.TargetNone
			update_hint_area(WRLD.get_mouse_game_position())

func _process(delta):
	if hint_area_type == ACT.TargetArea.TargetCone:
		var mouse_pos = WRLD.get_mouse_game_position()
		if mouse_pos != last_mouse_game_position:
			hint_cone_update(mouse_pos)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
