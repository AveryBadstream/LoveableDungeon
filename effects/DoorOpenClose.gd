extends GameEffect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func run_effect():
	if WRLD.cell_is_visible(effect_actor.game_position):
		EFCT.queue_effect(self)
		var cur_frame = effect_actor.frame
		var next_frame = ( effect_actor.frame + 1 ) % 2
		var tween:Tween = WRLD.get_free_tween()
		tween.interpolate_property(effect_actor, "frame", cur_frame, next_frame, .1, Tween.TRANS_QUAD, Tween.EASE_OUT)
		AUD.play_sound(AUD.SFX.Door)
		tween.start()
		yield(tween, "tween_all_completed")
	else:
		effect_actor.frame =  ( effect_actor.frame + 1 ) % 2
	effect_target.opened = !effect_target.opened
	EFCT.effect_done(self)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
