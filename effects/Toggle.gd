extends GameEffect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _init(actor, target).(actor, target):
	pass

func prep():
	effect_hint_mask |= EFCT.EffectHint.Interact | EFCT.EffectHint.Triggered
	return true

func run():
	var visible = WRLD.cell_is_visible(effect_actor.game_position) or WRLD.cell_is_visible(effect_target.game_position)
	effect_target.toggle(visible)
	if FX.in_priority:
		yield(FX, "priority_over")
	EVNT.emit_signal("effect_done", self)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
