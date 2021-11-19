extends GameEffect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var from
var towards
var to
var magnitude
var slamming_into = null

func _init(actor, target, direction, from_whence, current_magnitude).(actor, target):
	towards = direction
	magnitude = current_magnitude
	from = from_whence
	to = (towards).snapped(Vector2.ONE)  + from

func prep():
	if WRLD.cell_occupied(to) and magnitude > 0:
		slamming_into = WRLD.get_cell_occupier(to)
		return true
	return false

func run():
	if (WRLD.cell_is_visible(effect_actor.game_position) or WRLD.cell_is_visible(effect_target.game_position)):
		var tween:Tween = FX.get_free_tween()
		var slam_point = ((towards * 1/3)+from) * 16 
		var _t = tween.interpolate_property(effect_target, "position", from * 16, slam_point, 0.03, Tween.TRANS_QUAD, Tween.EASE_OUT)
		_t = tween.interpolate_property(effect_target, "position", slam_point, from * 16, 0.03, Tween.TRANS_QUAD, Tween.EASE_IN, 0.03)
		_t = tween.start()
		yield(tween, "tween_all_completed")
	MSG.effect_log(self, "{object} slammed into {third_party}!", {"third_party": slamming_into})
	if not effect_target.resist_effect(GameStats.MIGHT, magnitude):
		effect_target.take_damage(slamming_into, magnitude, GameStats.DamageTypes.Blunt)
#	if not slamming_into.resist_effect(GameStats.MIGHT, magnitude) and not slamming_into.is_immovable:
#		EFCT.queue_next(push_effect.new(effect_target, slamming_into, magnitude))
	EVNT.emit_signal("effect_done", self)
