extends GameEffect

func _init(actor).(actor, actor):
	pass

func prep():
	FX.die(effect_actor)
	return true

func run():
	AUD.play_sound(AUD.SFX.Die)
	FX.ready(1)
	yield(EVNT, "FX_complete")
	MSG.effect_log(self, "{subject} died!")
	EVNT.emit_signal("died", effect_actor)
	EVNT.emit_signal("effect_done", self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
