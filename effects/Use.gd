extends GameEffect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var from
var to
var target_cell

func _init(parent, actor, target).(parent, actor, target):
	effect_actor = actor
	from = effect_actor.position
	var target_at = target.game_position
	to = (target_at * 16) - (Vector2.ONE * 1/3)
	target_cell = target_at

func setup():
	self.effect_hint_mask |= EFCT.EffectHint.Interact

func run_effect():
	running = true
	if WRLD.cell_is_visible(effect_actor.game_position) or WRLD.cell_is_visible(effect_target.game_position):
		EFCT.queue_effect(self)
		var tween:Tween = WRLD.get_free_tween()
		tween.interpolate_property(effect_actor, "position", from, to, 0.05, Tween.TRANS_QUAD, Tween.EASE_OUT)
		tween.interpolate_property(effect_actor, "position", to, from, 0.05, Tween.TRANS_QUAD, Tween.EASE_IN, 0.05)
		tween.start()
		yield(tween, "tween_all_completed")
		EFCT.effect_done(self)
	running = false
	emit_signal("effect_done")

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
