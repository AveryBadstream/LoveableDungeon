extends GameEffect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var from
var to
var target_cell
# Called when the node enters the scene tree for the first time.

func _init(action, to_cell).(action, action.action_actor):
	from = action.action_actor.position
	to = to_cell * 16
	target_cell = to_cell

func run_effect():
	if WRLD.cell_is_visible(effect_action.action_actor.game_position) or WRLD.cell_is_visible(target_cell):
		EFCT.queue_effect(self)
		var tween:Tween = WRLD.get_free_tween()
		tween.interpolate_property(effect_target, "position", from, to, 0.1, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tween.start()
		AUD.play_sound(AUD.SFX.Footstep)
		yield(tween, "tween_all_completed")
	effect_target.game_position = target_cell
	EFCT.effect_done(self)
	effect_action.effect_done(self)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
