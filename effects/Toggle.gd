extends GameEffect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


func _init(parent, toggle_object, targets).(parent, toggle_object, targets):
	pass

func setup():
	effect_hint_mask |= EFCT.EffectHint.Interact | EFCT.EffectHint.Triggered

func pre_notify():
	for target in effect_target:
		process_pre_effect_response(target.effect_pre(self))

func post_notify():
	for target in effect_target:
		process_post_effect_response(target.effect_post(self))

func run_effect():
	var visible = WRLD.cell_is_visible(effect_actor.game_position) or WRLD.cell_is_visible(effect_actor.game_position)
	effect_actor.toggle(visible)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
