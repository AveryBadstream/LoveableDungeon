extends GameEffect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _init(parent, actor, target).(parent, actor, target):
	pass
# Called when the node enters the scene tree for the first time.
func run_effect():
	var visible = WRLD.cell_is_visible(effect_target.game_position) and WRLD.cell_is_visible(effect_actor.game_position)
	effect_target.open(visible)
	EFCT.effect_done(self)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
