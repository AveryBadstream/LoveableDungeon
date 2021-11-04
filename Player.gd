extends GameActor


signal message_0(msg)
signal try_action_at(actor, action, action_position)

export(ACT.Actions) var default_move = ACT.Actions.BasicMove
export(ACT.Actions) var default_open = ACT.Actions.BasicOpen
export(ACT.Actions) var default_close = ACT.Actions.BasicClose
export(ACT.Actions) var default_push = ACT.Actions.Push
export(ACT.Actions) var default_use = ACT.Actions.BasicUse

var local_default_actions = {}

var opens_doors = true
var pending_action = ACT.Type.None
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func _input(event):
	if !event.is_pressed() or self.acting_state == ACT.ActingState.Wait:
		return
	if event is InputEventMouseButton:
			if event.button_index == BUTTON_LEFT and event.pressed:
				var m_cell = WRLD.get_mouse_game_position()
				if not act_at_location(m_cell):
					var at_cell = (m_cell - get_game_position()).normalized().snapped(Vector2(1,1))
					act_in_direction(at_cell)
	if event.is_action("move_left"):
		act_in_direction(Vector2.LEFT)
	elif event.is_action("move_right"):
		act_in_direction(Vector2.RIGHT)
	elif event.is_action("move_up"):
		act_in_direction(Vector2.UP)
	elif event.is_action("move_down"):
		act_in_direction(Vector2.DOWN)
	elif event.is_action("open"):
		pending_action = local_default_actions[ACT.Type.Open]
		pending_action.mark_pending()
	elif event.is_action("close"):
		pending_action = local_default_actions[ACT.Type.Close]
		pending_action.mark_pending()
	elif event.is_action("push"):
		pending_action = local_default_actions[ACT.Type.Push]
		pending_action.mark_pending()
	elif event.is_action("move"):
		pending_action = local_default_actions[ACT.Type.Move]
		pending_action.mark_pending()
	elif event.is_action("forcewave"):
		pending_action = local_actions[ACT.Type.Push][0]
		pending_action.mark_pending()
		
func act_at_location(at_cell: Vector2):
	if not pending_action:
		for hint in WRLD.get_action_hints(at_cell.round()):
			if local_default_actions.has(hint):
				var candidate_action = local_default_actions[hint]
				if candidate_action.test_action_at(at_cell):
					acting_state = ACT.ActingState.Wait
					candidate_action.do_action_at(at_cell)
					return true
	else:
		var next_action = pending_action
		pending_action = ACT.Type.None
		EVNT.emit_signal("hint_area_none")
		next_action.do_action_at(at_cell)
		return true
	return false
	
func act_in_direction(dir: Vector2):
	if not pending_action:
		var action_hint = WRLD.get_action_hint(self.get_game_position() + dir)
		print("Got default action: " + ACT.Type.keys()[action_hint])
		if local_default_actions.has(action_hint):
			acting_state = ACT.ActingState.Wait
			local_default_actions[action_hint].do_action_at(self.get_game_position() + dir)
		else:
			return
	else:
		var next_action = pending_action
		pending_action = ACT.Type.None
		EVNT.emit_signal("hint_area_none")
		next_action.do_action_at(self.get_game_position() + dir)
# Called when the node enters the scene tree for the first time.
func _ready():
	is_player = true
	local_default_actions[ACT.Type.Move] = ACT.ActionMapping[default_move].new(self)
	local_default_actions[ACT.Type.Open] = ACT.ActionMapping[default_open].new(self)
	local_default_actions[ACT.Type.Close] = ACT.ActionMapping[default_close].new(self)
	local_default_actions[ACT.Type.Push] = ACT.ActionMapping[default_push].new(self)
	local_default_actions[ACT.Type.Use] = ACT.ActionMapping[default_use].new(self)
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
