extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var area_hint_indicator = preload("res://ui/AreaHintRect.tscn")

onready var area_highlight = $AreaHighlight

var hint_area_type = ACT.TargetArea.TargetNone
var hint_area_args = []
var last_mouse_game_position = Vector2.ZERO
# Called when the node enters the scene tree for the first time.
func _ready():
	EVNT.subscribe("hint_area_cone", self, "_on_hint_area_cone")# Replace with function body.

func _on_hint_area_cone(from, radius, width):
	var mouse_pos = WRLD.get_mouse_game_position()
	hint_area_args = [from, radius, width]
	hint_area_type = ACT.TargetArea.TargetCone
	hint_cone_update(mouse_pos)

func hint_cone_update(mouse_pos):
	last_mouse_game_position = mouse_pos
	for hint in area_highlight.get_children():
		area_highlight.remove_child(hint)
		hint.queue_free()
	var cells = FOV.cast_cone_at(hint_area_args[0], mouse_pos, hint_area_args[2], hint_area_args[1], WRLD.GameWorld.fov_block_map)
	for cell in cells:
		var new_hint:ColorRect = area_hint_indicator.instance()
		new_hint.rect_position = cell * 16
		area_highlight.add_child(new_hint)

func _process(delta):
	if hint_area_type == ACT.TargetArea.TargetCone:
		var mouse_pos = WRLD.get_mouse_game_position()
		if mouse_pos != last_mouse_game_position:
			hint_cone_update(mouse_pos)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
