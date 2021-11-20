extends GameActor

var opens_doors = true
var pending_action = ACT.Type.None
var experience = 0
var pending_levelup = false

func gain_experience(t_level):
	var xp_mult = clamp(game_stats.get_stat(GameStats.LEVEL) + ((t_level - game_stats.get_stat(GameStats.LEVEL)) * 0.2),0,2)
	var n_exp = clamp(100 - ( (game_stats.get_stat(GameStats.LEVEL) - 3 ) * 10), 50, 100) if game_stats.get_stat(GameStats.LEVEL) > 1 else 200
	experience += n_exp*xp_mult
	if experience >= 1000 and not pending_levelup:
		MSG.game_log("[rainbow freq=0.2 sat=10 val=20][shake rate=5 level=10]You level up![/shake][/rainbow]")
		AUD.play_sound(AUD.SFX.LevelUp)
		pending_levelup = true
	EVNT.emit_signal("player_stats", self)

func level_up(stat):
	if experience < 1000:
		return
	experience -= 1000
	var old_hp_max = game_stats.get_raw_stat(GameStats.HP)
	var old_max_stamina = game_stats.get_raw_stat(GameStats.STAMINA)
	game_stats.change_stat(stat, 1, true)
	game_stats.change_stat(GameStats.LEVEL, 1, true)
	var level = game_stats.get_raw_stat(GameStats.LEVEL)
	var fortitude = game_stats.get_raw_stat(GameStats.FORTITUDE)
	var new_hp = 10 + (fortitude * level)
	var new_stamina = fortitude + 1
	game_stats.set_stat(GameStats.HP, new_hp, true)
	game_stats.change_resource(GameStats.HP, new_hp - old_hp_max)
	game_stats.set_stat(GameStats.STAMINA, new_stamina, true)
	game_stats.change_resource(GameStats.STAMINA, new_stamina - old_max_stamina, true)
	if experience < 1000:
		pending_levelup = false
	EVNT.emit_signal("player_stats", self)

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
