extends GameEffect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var slide_effect = preload("res://effects/Slide.gd")

# Called when the node enters the scene tree for the first time.
var from
var to
# Called when the node enters the scene tree for the first time.

func _init(parent, actor, target, magnitude).(parent, actor, target):
	from = target.game_position
	var possible_target = (((from - actor.game_position) * magnitude) + from).snapped(Vector2.ONE)
	steps = FOV.cast_lerp_line(target.game_position, possible_target, magnitude, WRLD.GameWorld.fov_block_map)
	var i = steps.size() - 1
	to = steps[i]
	steps.remove(i)
	i -= 1
	var last_added = self
	var last_position = to
	while i >=0:
		var next_effect = slide_effect.new(last_added, actor, target, last_position, steps[i])
		last_position = steps[i]
		steps.remove(i)
		last_added.after_queue.append(next_effect)
		last_added = next_effect
		i -= 1

func run_effect():
	running = true
	effect_target.set_game_position(to, false)
	if WRLD.cell_is_visible(from) or WRLD.cell_is_visible(to):
		EFCT.queue_effect(self)
		var tween:Tween = WRLD.get_free_tween()
		tween.interpolate_property(effect_target, "position", from * 16, to * 16, .1, Tween.TRANS_CUBIC, Tween.EASE_IN)
		FX.spawn_puff(from)
		AUD.play_sound(AUD.SFX.JailBars)
		tween.start()
		yield(tween, "tween_all_completed")
		EFCT.effect_done(self)
	running = false
	emit_signal("effect_done", self)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
