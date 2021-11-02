extends GameEffect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _init(parent, targets).(parent, targets):
	pass

func run_effect():
	if WRLD.cell_is_visible(effect_action.game_position):
		EFCT.queue_effect(self)
		AUD.play_sound(AUD.SFX.Switch)
		var cur_frame = effect_action.frame
		var next_frame = ( effect_action.frame + 1 ) % 2
		var tween:Tween = WRLD.get_free_tween()
		tween.interpolate_property(effect_action, "frame", cur_frame, next_frame, 0.1, Tween.TRANS_QUAD, Tween.EASE_OUT)
		tween.start()
		yield(tween, "tween_all_completed")
	for target in effect_target:
		target._on_toggle(effect_action)
	EFCT.effect_done(self)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
