extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var area_hint_indicator = preload("res://ui/AreaHint.tscn")
var target_hint_indicator = preload("res://ui/TargetHint.tscn")
var effect_hint_indicator = preload("res://ui/EffectHint.tscn")
onready var angle_line = $Line2D

onready var area_highlight = $AreaHighlight

var hint_area_type = ACT.TargetArea.TargetNone
var currently_hinting
var last_mouse_game_position = Vector2.ZERO
var last_octant = null
# Called when the node enters the scene tree for the first time.
func _ready():
	EVNT.subscribe("hint_action", self, "_on_hint_action")
	EVNT.subscribe("action_complete", self, "_on_end_hint")
	EVNT.subscribe("action_impossible", self, "_on_end_hint")
	EVNT.subscribe("action_failed", self, "_on_end_hint")

func _on_end_hint(action):
	currently_hinting = null
	clear_hints()

func _on_hint_action(action):
	currently_hinting = action
	display_hints(action.get_target_hints())

func display_hints(hint_lists):
	clear_hints()
	for cell in hint_lists[0]:
		var new_hint:ColorRect = area_hint_indicator.instance()
		new_hint.rect_position = cell * 16
		area_highlight.add_child(new_hint)
	for cell in hint_lists[1]:
		var new_hint:ColorRect = effect_hint_indicator.instance()
		new_hint.rect_position = cell * 16
		area_highlight.add_child(new_hint)
	for cell in hint_lists[2]:
		var new_hint:ColorRect = target_hint_indicator.instance()
		new_hint.rect_position = cell * 16
		area_highlight.add_child(new_hint)

func clear_hints():
	for child in area_highlight.get_children():
		area_highlight.remove_child(child)
		child.queue_free()

func hint_update(mouse_pos):
	display_hints(currently_hinting.get_target_hints(mouse_pos))

func _process(delta):
	var mouse_pos = WRLD.get_mouse_game_position()
	if currently_hinting:
		if mouse_pos != last_mouse_game_position:
			hint_update(mouse_pos)
	last_mouse_game_position = mouse_pos
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
