extends GameEffect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var slide_effect = preload("res://effects/Slide.gd")
var slam_effect = preload("res://effects/Slam.gd")

# Called when the node enters the scene tree for the first time.
var from
var to
var should_slam = false
var magnitude
var direction
# Called when the node enters the scene tree for the first time.

func _init(actor, target, set_magnitude).(actor, target):
	from = target.game_position
	if set_magnitude.is_valid_integer():
		magnitude = max(1, int(set_magnitude))
	else:
		magnitude = max(1, actor.game_stats.get_stat(set_magnitude))
	print(magnitude)
	direction = (from - actor.game_position).normalized()
	var possible_target = ((direction * magnitude) + from).snapped(Vector2.ONE)
	print(possible_target)
	steps = FOV.lerp_line(target.game_position, possible_target, magnitude, TIL.CellInteractions.None)
	print(steps)
	step = 0
	to = steps[0]

func prep():
	if WRLD.cell_occupied(steps[step]):
		EFCT.queue_now(slam_effect.new(effect_actor, effect_target, direction, effect_target.game_position, magnitude))
		return false
	elif steps.size() > 1:
		EFCT.queue_at_offset(slide_effect.new(effect_actor, effect_target, steps, step + 1, magnitude - 1), 1)
	else:
		EFCT.queue_at_offset(slam_effect.new(effect_actor, effect_target, direction, steps[step], magnitude - 1), 1)
	return true

func run():
	if WRLD.cell_is_visible(from) or WRLD.cell_is_visible(to):
		effect_target.set_game_position(to, false)
		var tween:Tween = FX.get_free_tween()
		tween.interpolate_property(effect_target, "position", from * 16, to * 16, .1, Tween.TRANS_CUBIC, Tween.EASE_IN)
		FX.spawn_puff(from)
		AUD.play_sound(AUD.SFX.JailBars)
		tween.start()
		yield(tween, "tween_all_completed")
	else:
		effect_target.set_game_position(to)
	EVNT.emit_signal("effect_done", self)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
