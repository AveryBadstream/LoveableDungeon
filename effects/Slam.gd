extends GameEffect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var from
var towards
var to
var magnitude
var slamming_into = false

func _init(actor, target, direction, from_whence, current_magnitude).(actor, target):
	towards = direction
	magnitude = current_magnitude
	from = from_whence
	to = (towards + from).snapped(Vector2.ONE)

func prep():
	if WRLD.cell_occupied(to):
		slamming_into = true
	return true

func run():
	if (WRLD.cell_is_visible(effect_actor.game_position) or WRLD.cell_is_visible(effect_target.game_position)) and slamming_into:
		var tween:Tween = WRLD.get_free_tween()
		var slam_point = ((towards * 1/8)+from) * 16 
		tween.interpolate_property(effect_target, "position", from * 16, slam_point, 0.03, Tween.TRANS_QUAD, Tween.EASE_OUT)
		tween.interpolate_property(effect_target, "position", slam_point, from * 16, 0.03, Tween.TRANS_QUAD, Tween.EASE_IN, 0.03)
		tween.start()
		yield(tween, "tween_all_completed")
	EVNT.emit_signal("effect_done", self)
