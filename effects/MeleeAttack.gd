extends GameEffect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func _init(actor, target).(actor, target):
	pass

func prep():
	if not effect_actor.attack_roll(effect_target):
		MSG.effect_log(self, "{subject}{spos} attack missed {object}")
		return false
	return true

func run():
	var actor_from = (effect_actor.game_position) * 16
	var actor_to = actor_from + (((effect_target.game_position * 16) - actor_from).normalized()  * .3)
	var target_rest = effect_target.game_position * 16
	var target_l = Vector2(target_rest.x - .3, target_rest.y)
	var target_r = Vector2(target_rest.x + .3, target_rest.y)
	if WRLD.cell_is_visible(effect_actor.game_position) or WRLD.cell_is_visible(effect_target.game_position):
		var tween:Tween = WRLD.get_free_tween()
		tween.interpolate_property(effect_actor, "position", actor_from, actor_to, 0.05, Tween.TRANS_QUAD, Tween.EASE_OUT)
		tween.interpolate_property(effect_actor, "position", actor_to, actor_from, 0.05, Tween.TRANS_QUAD, Tween.EASE_IN, 0.05)
		tween.interpolate_property(effect_target, "position", target_rest, target_l, 0.025, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.05)
		tween.interpolate_property(effect_target, "position", target_l, target_r, 0.05, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.075)
		tween.interpolate_property(effect_target, "position", target_l, target_rest, 0.025, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.05)
		tween.start()
		yield(tween, "tween_all_completed")
	var damage = effect_actor.get_damage_dealt(effect_target)
	MSG.effect_log(self, "{subject} hit {object} for "+str(damage)+" points!")
	effect_target.take_damage(damage)
	EVNT.emit_signal("effect_done", self)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
