extends CanvasLayer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var area_hint_indicator = preload("res://ui/AreaHint.tscn")
var target_hint_indicator = preload("res://ui/TargetHint.tscn")
var effect_hint_indicator = preload("res://ui/EffectHint.tscn")

onready var Canvas = $CanvasLayer
onready var MessageBox = $PanelContainer/LogBox/VBoxContainer/MessageBox
onready var LogBox = $PanelContainer/LogBox/VBoxContainer/ScrollContainer/LogBox

enum UI_STATES {Wait, Active}

var active_player

var ui_state = UI_STATES.Wait

var OverlayTiles
var hint_area_type = ACT.TargetArea.TargetNone
var currently_hinting
var last_mouse_game_position = Vector2.ZERO
var last_octant = null

func _ready():
	MSG.MessageBox = MessageBox
	MSG.LogBox = LogBox
	WRLD.canvas_layer = Canvas
	EVNT.subscribe("hint_action", self, "_on_hint_action")
	EVNT.subscribe("action_complete", self, "_on_end_hint")
	EVNT.subscribe("action_impossible", self, "_on_end_hint")
	EVNT.subscribe("action_failed", self, "_on_end_hint")
	EVNT.subscribe("player_active", self, "_on_player_active")

func _on_player_active(player):
	active_player = player
	ui_state = UI_STATES.Active

func _on_end_hint(action):
	currently_hinting = null
	clear_hints()

func _on_hint_action(action):
	currently_hinting = action
	display_hints(action.get_target_hints())

func display_hints(hint_lists):
	clear_hints()
	for cell in hint_lists[0]:
		OverlayTiles.set_cellv(cell, 0)
	for cell in hint_lists[1]:
		OverlayTiles.set_cellv(cell, 1)
	for cell in hint_lists[2]:
		OverlayTiles.set_cellv(cell, 2)

func clear_hints():
	OverlayTiles.clear()

func hint_update(mouse_pos):
	display_hints(currently_hinting.get_target_hints(mouse_pos))

func _unhandled_input(event):
	if !event.is_pressed() or ui_state == UI_STATES.Wait:
		return
	if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT and event.pressed:
				var m_cell = WRLD.get_mouse_game_position()
				if not active_player.act_at_location(m_cell):
					var at_cell = FOV.cast_nearest_point(active_player.get_game_position(), m_cell, 1)
					active_player.act_at_location(at_cell)
	if event.is_action("move_left"):
		active_player.act_in_direction(Vector2.LEFT)
	elif event.is_action("move_right"):
		active_player.act_in_direction(Vector2.RIGHT)
	elif event.is_action("move_up"):
		active_player.act_in_direction(Vector2.UP)
	elif event.is_action("move_down"):
		active_player.act_in_direction(Vector2.DOWN)
	elif event.is_action("open"):
		active_player.pending_action = active_player.local_default_actions[ACT.Type.Open]
		active_player.pending_action.mark_pending()
	elif event.is_action("close"):
		active_player.pending_action = active_player.local_default_actions[ACT.Type.Close]
		active_player.pending_action.mark_pending()
	elif event.is_action("push"):
		active_player.pending_action = active_player.local_default_actions[ACT.Type.Push]
		active_player.pending_action.mark_pending()
	elif event.is_action("move"):
		active_player.pending_action = active_player.local_default_actions[ACT.Type.Move]
		active_player.pending_action.mark_pending()
	elif event.is_action("forcewave"):
		active_player.pending_action = active_player.local_actions[0]
		active_player.pending_action.mark_pending()
	elif event.is_action("vital_burst"):
		active_player.pending_action = active_player.local_default_actions[ACT.Type.Heal]
		active_player.pending_action.mark_pending()
	elif event.is_action("LevelUp"):
		active_player.gain_experience(100)

func _process(delta):
	if currently_hinting:
		var mouse_pos = WRLD.get_mouse_game_position()
		if mouse_pos != last_mouse_game_position:
			hint_update(mouse_pos)
		last_mouse_game_position = mouse_pos
