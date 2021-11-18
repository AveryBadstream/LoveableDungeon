extends GameEffect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _init(actor, target).(actor, target):
	pass

func prep():
	FX.bump_into(effect_actor, effect_target)
	return true

func run():
	FX.ready(1)
	AUD.play_sound(AUD.SFX.Swing)
	yield(EVNT, "FX_complete")
	if not ACT.attack_roll(effect_actor.game_stats.get_stat(GameStats.AGILITY) + effect_actor.game_stats.get_stat(GameStats.MIGHT), \
		effect_target.game_stats.get_stat(GameStats.ARMOR) + effect_target.game_stats.get_stat(GameStats.AGILITY)):
		MSG.effect_log(self, "{subject}{spos} attack missed {object}")
	else:
		for attack_part in effect_actor.game_stats.basic_attack:
			effect_target.take_damage(effect_actor, ACT.roll_damage(attack_part[0], effect_actor.game_stats), attack_part[0])
	EVNT.emit_signal("effect_done", self)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
