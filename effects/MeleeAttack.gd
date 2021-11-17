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
	if not effect_actor.attack_roll(effect_target):
		MSG.effect_log(self, "{subject}{spos} attack missed {object}")
	else:
		effect_target.take_damage(effect_actor, effect_actor.get_damage_dealt(effect_target))
	EVNT.emit_signal("effect_done", self)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
