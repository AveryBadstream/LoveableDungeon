extends GameEffect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var from
var to

func _init(actor, target).(actor, target):
	pass
# Called when the node enters the scene tree for the first time.
func run():
	var visible = WRLD.cell_is_visible(effect_target.game_position) or WRLD.cell_is_visible(effect_actor.game_position)
	effect_target.open(visible)
	if FX.in_priority:
		yield(FX, "priority_over")
	EVNT.emit_signal("effect_done", self)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
