extends GameEffect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
var from
var to
# Called when the node enters the scene tree for the first time.

func _init(parent, actor, target, from_cell, to_cell).(parent, actor, target):
	from = from_cell
	to = to_cell
	

func run_effect():
	running = true
	effect_target.set_game_position(to, false)
	if WRLD.cell_is_visible(from) or WRLD.cell_is_visible(to):
		EFCT.queue_effect(self)
		var tween:Tween = WRLD.get_free_tween()
		tween.interpolate_property(effect_target, "position", from * 16, to * 16, 0.07, Tween.TRANS_LINEAR, Tween.EASE_IN)
		FX.spawn_puff(from)
		AUD.play_sound(AUD.SFX.Footstep)
		tween.start()
		yield(tween, "tween_all_completed")
		EFCT.effect_done(self)
	running = false
	emit_signal("effect_done", self)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
