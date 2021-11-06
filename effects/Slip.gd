extends GameEffect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var slide_effect = preload("res://effects/Slide.gd")
var slam_effect = preload("res://effects/Slam.gd")

# Called when the node enters the scene tree for the first time.
var from
var to
var should_slam = false
var direction
# Called when the node enters the scene tree for the first time.

func _init(actor, target, in_direction).(actor, target):
	from = target.game_position
	direction = in_direction
	var possible_target = ((direction) + from).snapped(Vector2.ONE)
	steps = FOV.cast_lerp_line(target.game_position, possible_target, 1, TIL.CellInteractions.None)
	step = 0
	to = steps[0]

func prep():
	print("Prepping slip for "+effect_target.name+" from:"+str(from)+" to:"+str(to))
	if WRLD.cell_occupied(steps[1]):
		print("Slamming")
		EFCT.queue_now(slam_effect.new(effect_actor, effect_target, direction, effect_target.game_position, 1))
	else:
		print("Sliding")
		EFCT.queue_now(slide_effect.new(effect_actor, effect_target, steps, 1, 1))
	return false

func run():
	EVNT.emit_signal("effect_done", self)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
