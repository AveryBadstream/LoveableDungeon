extends GameEffect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _init(parent, actor, target).(parent, actor, target):
	pass
# Called when the node enters the scene tree for the first time.
func run_effect():
	running = true
	var visible = WRLD.cell_is_visible(effect_target.game_position) or WRLD.cell_is_visible(effect_actor.game_position)
	if visible:
		EFCT.queue_effect(self)
	effect_target.open(visible)
	if FX.in_priority:
		yield(FX, "priority_over")
	if visible:
		EFCT.effect_done(self)
	running = false
	emit_signal("effect_done")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
