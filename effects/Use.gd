extends GameEffect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var from
var to
var target_cell

func _init(action, target_at).(action, action.action_actor):
	from = action.action_actor.position
	to = (target_at * 16) - (Vector2.ONE * 1/3)
	target_cell = target_at

func run_effect():
	if WRLD.cell_is_visible(effect_action.action_actor.game_position) or WRLD.cell_is_visible(target_cell):
		EFCT.queue_effect(self)
		var tween:Tween = WRLD.get_free_tween()
		tween.interpolate_property(effect_target, "position", from, to, 0.05, Tween.TRANS_QUAD, Tween.EASE_OUT)
		tween.interpolate_property(effect_target, "position", to, from, 0.05, Tween.TRANS_QUAD, Tween.EASE_IN, 0.05)
		tween.start()
		yield(tween, "tween_all_completed")
	EFCT.effect_done(self)
	effect_action.effect_done(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
