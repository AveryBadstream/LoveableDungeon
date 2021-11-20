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
	steps = [from]
	steps.append_array(FOV.lerp_line(target.game_position, possible_target, 1, TIL.CellInteractions.None))
	step = 1
	to = steps[1]
	print(len(steps))

func prep():
	if WRLD.cell_occupied(steps[step]):
		EFCT.queue_now(slam_effect.new(effect_actor, effect_target, direction, effect_target.game_position, 1))
	else:
		EFCT.queue_now(slide_effect.new(effect_actor, effect_target, steps, step, 1))
	return false

func run():
	EVNT.emit_signal("effect_done", self)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
