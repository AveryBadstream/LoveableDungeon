extends GameActor

var opens_doors = true
var pending_action = ACT.Type.None
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#func _input(event):
#	if !event.is_pressed() or self.acting_state == ACT.ActingState.Wait:
#		return
#	if event is InputEventMouseButton:
#			if event.button_index == BUTTON_LEFT and event.pressed:
#				var m_cell = WRLD.get_mouse_game_position()
#				if not act_at_location(m_cell):
#					var at_cell = FOV.cast_nearest_point(get_game_position(), m_cell, 1)
#					act_at_location(at_cell)
#	if event.is_action("move_left"):
#		act_in_direction(Vector2.LEFT)
#	elif event.is_action("move_right"):
#		act_in_direction(Vector2.RIGHT)
#	elif event.is_action("move_up"):
#		act_in_direction(Vector2.UP)
#	elif event.is_action("move_down"):
#		act_in_direction(Vector2.DOWN)
#	elif event.is_action("open"):
#		pending_action = local_default_actions[ACT.Type.Open]
#		pending_action.mark_pending()
#	elif event.is_action("close"):
#		pending_action = local_default_actions[ACT.Type.Close]
#		pending_action.mark_pending()
#	elif event.is_action("push"):
#		pending_action = local_default_actions[ACT.Type.Push]
#		pending_action.mark_pending()
#	elif event.is_action("move"):
#		pending_action = local_default_actions[ACT.Type.Move]
#		pending_action.mark_pending()
#	elif event.is_action("forcewave"):
#		pending_action = local_actions[0]
#		pending_action.mark_pending()
		
func act_at_location(at_cell: Vector2):
	if self.acting_state != ACT.ActingState.Act:
		return
	if not pending_action:
		var distance_to = at_cell.distance_to(get_game_position())
		for hint in WRLD.get_action_hints(at_cell):
			if local_default_actions.has(hint):
				var candidate_action = local_default_actions[hint]
				if distance_to <= candidate_action.action_range:
					if candidate_action.test_action_at(at_cell):
						acting_state = ACT.ActingState.Wait
						candidate_action.do_action_at(at_cell)
						return true
#					for action in local_default_actions.values():
#						if action.range <= distance_to:
	else:
		var next_action = pending_action
		pending_action = ACT.Type.None
		EVNT.emit_signal("hint_area_none")
		next_action.do_action_at(at_cell)
		return true
	return false
	
func act_in_direction(dir: Vector2):
	if self.acting_state != ACT.ActingState.Act:
		return
	if not pending_action:
		var action_hint = WRLD.get_action_hint(self.get_game_position() + dir)
		print("Got default action: " + ACT.TypeKey(action_hint))
		if default_actions.has(action_hint):
			acting_state = ACT.ActingState.Wait
			local_default_actions[action_hint].do_action_at(self.get_game_position() + dir)
		else:
			return
	else:
		var next_action = pending_action
		pending_action = ACT.Type.None
		next_action.do_action_at(self.get_game_position() + dir)
# Called when the node enters the scene tree for the first time.
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
