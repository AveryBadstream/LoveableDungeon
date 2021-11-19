extends GameAction


export(Script) var heal_effect = preload("res://effects/Push.gd")
export(String) var heal_effect_roll = "1+1d6"

func post_validate(targets):
	var remove_targets = []
	for target in targets:
		if target.game_stats and target.game_stats.get_resource(GameStats.HP) < target.game_stats.get_stat(GameStats.HP):
			continue
		else:
			remove_targets.append(target)
	for target in remove_targets:
		targets.erase(target)
	return true

func do():
	for target in self.action_targets:
		EFCT.queue_now(heal_effect.new(self.action_actor, target, heal_effect_roll))
