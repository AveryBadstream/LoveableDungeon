extends GameEffect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
var from
var push_line
var last_i
var next_step
var ease_type = Tween.EASE_IN
var trans_type = Tween.TRANS_CUBIC
var tween_speed = 0.1
# Called when the node enters the scene tree for the first time.

func _init(action, actor, target, magnitude).(action, actor, target):
	from = target.game_position
	if steps.size() == 0:
		var possible_target = (((from - actor.game_position) * magnitude) + from).snapped(Vector2.ONE)
		steps = FOV.cast_lerp_line(target.game_position, possible_target, magnitude, WRLD.GameWorld.fov_block_map)
	last_i = steps.size()-1
	next_step = steps[last_i]
	steps.remove(last_i)
	running = true
	target.effect_claim(self)
	

func run_effect():
	if last_i == 0:
		effect_target.effect_release(self)
	if WRLD.cell_is_visible(from) or WRLD.cell_is_visible(next_step):
		var tween:Tween = WRLD.get_free_tween()
		tween.interpolate_property(effect_target, "position", from * 16, next_step * 16, tween_speed, trans_type, ease_type)
		FX.spawn_puff(from)
		tween.start()
		AUD.play_sound(AUD.SFX.Footstep)
		yield(tween, "tween_all_completed")
	effect_target.game_position = next_step
	yield(effect_target, "position_update_complete")
	if last_i == 0:
		running = false
		emit_signal("effect_done", self)
		EFCT.effect_done(self)
	else:
		trans_type = Tween.TRANS_LINEAR
		tween_speed = 0.7
		last_i -= 1
		from = next_step
		next_step = steps[last_i]
		steps.remove(last_i)
		emit_signal("effect_done", self)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
