extends GameEffect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var slam_effect = preload("res://effects/Slam.gd")

# Called when the node enters the scene tree for the first time.
var magnitude
var from
var to
# Called when the node enters the scene tree for the first time.

func _init(actor, target, all_steps, step_i, current_magnitude).(actor, target):
	steps = all_steps
	step = step_i
	from = steps[step-1]
	to = steps[step]
	magnitude = current_magnitude

func prep():
	if WRLD.cell_occupied(steps[step]):
		EFCT.queue_now(slam_effect.new(effect_actor, effect_target, (steps[step] - steps[step-1]).normalized(), steps[step-1], magnitude))
		return false
	elif steps.size() > step + 1:
		EFCT.queue_at_offset(get_script().new(effect_actor, effect_target, steps, step + 1, magnitude - 1), 1)
	return true

func run():
	if WRLD.cell_is_visible(from) or WRLD.cell_is_visible(to):
		var tween:Tween = WRLD.get_free_tween()
		tween.interpolate_property(effect_target, "position", from * 16, to * 16, 0.02, Tween.TRANS_LINEAR, Tween.EASE_IN)
		FX.spawn_puff(from)
		AUD.play_sound(AUD.SFX.Footstep)
		tween.start()
		yield(tween, "tween_all_completed")
		effect_target.set_game_position(to, false)
	else:
		effect_target.set_game_position(to, true)
	EVNT.emit_signal("effect_done", self)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
