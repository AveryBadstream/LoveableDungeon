extends GameEffect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var from
var to
var target_cell
# Called when the node enters the scene tree for the first time.

func _init(actor, target, to_cell).(actor, target):
	from = target.position
	to = to_cell * 16
	target_cell = to_cell

func run():
	if WRLD.cell_is_visible(effect_actor.game_position) or WRLD.cell_is_visible(target_cell):
		effect_actor.set_game_position(target_cell, false)
		var tween:Tween = WRLD.get_free_tween()
		tween.interpolate_property(effect_actor, "position", from, to, 0.05, Tween.TRANS_SINE, Tween.EASE_IN_OUT)
		tween.start()
		AUD.play_sound(AUD.SFX.Footstep)
		yield(tween, "tween_all_completed")
	else:
		effect_actor.game_position = target_cell
	effect_actor.game_position = target_cell
	EVNT.emit_signal("effect_done", self)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
