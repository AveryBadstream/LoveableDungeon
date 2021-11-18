extends GameEffect

var damage

func _init(actor, target, damage_dealt, damage_type).(actor, target):
	damage = damage_dealt

func prep():
	if damage > 0:
		FX.fast_wobble(effect_target)
		return true
	else:
		MSG.effect_log(self, "{subject} took no damage from {object}")
		return false

func run():
	AUD.play_sound(AUD.SFX.Hit)
	FX.ready(1)
	yield(EVNT, "FX_complete")
	effect_target.game_stats.change_resource(GameStats.HP, -1 * damage)
	MSG.effect_log(self, "{subject} dealt {damage} damage to {object}", {"damage": damage})
	effect_target.check_dead()
	EVNT.emit_signal("effect_done", self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
