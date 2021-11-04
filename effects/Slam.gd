extends GameEffect


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var from
var towards
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _init(parent, actor, target, magnitude).(parent, actor, target):
	from = target.game_position
	var possible_target = (((from - actor.game_position).normalized() * magnitude) + from).snapped(Vector2.ONE)
	steps = FOV.cast_lerp_line(target.game_position, possible_target, magnitude, WRLD.GameWorld.fov_block_map)
	var i = steps.size() - 1
	to = steps[i]
	steps.remove(i)
	i -= 1
	var last_added = self
	var last_position = to
	while i >=0:
		var next_effect = slide_effect.new(last_added, actor, target, last_position, steps[i])
		last_position = steps[i]
		steps.remove(i)
		last_added.after_queue.append(next_effect)
		last_added = next_effect
		i -= 1

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
