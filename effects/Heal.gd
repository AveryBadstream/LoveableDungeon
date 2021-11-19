extends GameEffect


var heal_roll
# Called when the node enters the scene tree for the first time.

func _init(actor, target, heal_roll_def).(actor, target):
	heal_roll = heal_roll_def

func run():
	if WRLD.cell_is_visible(effect_target.game_position):
		FX.spawn_heal_bubble(effect_target.game_position)
		AUD.play_sound(AUD.SFX.Heal)
	var heal_amount = ACT.roll_damage(heal_roll, effect_actor.game_stats)
	effect_target.game_stats.change_resource(GameStats.HP, heal_amount)
	MSG.effect_log(self, "{object} healed for "+str(heal_amount)+".")
	EVNT.emit_signal("effect_done", self)
