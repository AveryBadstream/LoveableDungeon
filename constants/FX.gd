extends Node

signal priority_over()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var puff = preload("res://fx/Puff.tscn")

var in_priority = false

var free_tweens = []
var tweens = []

var managed_tweens = []

var fx_count = 0

var running_count = 0

var FXManager
# Called when the node enters the scene tree for the first time.
func _ready():
	EVNT.subscribe("queue_complete", self, "_on_queue_complete") # Replace with function body.

func _on_queue_complete():
	free_tweens = tweens.duplicate()

func spawn_puff(game_position):
	var new_puff = puff.instance()
	new_puff.position = game_position * 16
	FXManager.add_child(new_puff)

func bump_into(bumper, bumpee, after=0):
	if WRLD.cell_is_visible(bumper.game_position) or WRLD.cell_is_visible(bumpee.game_position):
		var tween:Tween = get_free_tween()
		managed_tweens.append(tween)
		var from = bumper.position
		var to = from + ((bumpee.position - from) * 3/5)
		tween.interpolate_property(bumper, "position", from, to, 0.025,Tween.TRANS_CUBIC, Tween.EASE_IN, after)
		tween.interpolate_property(bumper, "position", to, from, 0.025, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.025+after)
		fx_count += 1
		return 0.05
	return 0.05

func fast_wobble(wobbler, after=0):
	if WRLD.cell_is_visible(wobbler.game_position):
		var target_rest = wobbler.position
		var target_l = Vector2(target_rest.x - 5, target_rest.y)
		var target_r = Vector2(target_rest.x + 5, target_rest.y)
		var tween:Tween = get_free_tween()
		managed_tweens.append(tween)
		tween.interpolate_property(wobbler, "position", target_rest, target_l, 0.025, Tween.TRANS_CUBIC, Tween.EASE_OUT, after)
		tween.interpolate_property(wobbler, "position", target_l, target_r, 0.05, Tween.TRANS_LINEAR, Tween.EASE_OUT, 0.025+after)
		tween.interpolate_property(wobbler, "position", target_l, target_rest, 0.025, Tween.TRANS_CUBIC, Tween.EASE_OUT, 0.05+after)
		fx_count += 1
		return 0.075
	return 0

func die(dead_thing, after=0):
	if WRLD.cell_is_visible(dead_thing.game_position):
		var tween:Tween = get_free_tween()
		managed_tweens.append(tween)
		for i in range(10):
			tween.interpolate_property(dead_thing, "modulate:a", 1, 0, 0.01, Tween.TRANS_LINEAR, Tween.EASE_IN, after+(i*0.02))
			tween.interpolate_property(dead_thing, "modulate:a", 0, 1, 0.01, Tween.TRANS_LINEAR, Tween.EASE_IN, after+(i*0.02)+0.01)
			tween.interpolate_property(dead_thing, "scale", Vector2(1,1), Vector2(1.5, 1.5), 0.2, Tween.TRANS_CUBIC, Tween.EASE_IN)
			tween.interpolate_property(dead_thing, "offset", Vector2(0,0), Vector2(-4, -4), 0.2, Tween.TRANS_CUBIC, Tween.EASE_IN)
		fx_count += 1
		return 0.2
	return 0

func ready(count):
	fx_count -= count
	if fx_count <= 0:
		start_fx()

func start_fx():
	for tween in managed_tweens:
		tween.connect("tween_all_completed", self, "_on_tween_all_completed")
		running_count += 1
		tween.call_deferred("start")

func _on_tween_all_completed():
	running_count -= 1
	if running_count <= 0:
		for tween in managed_tweens:
			tween.disconnect("tween_all_completed", self, "_on_tween_all_completed")
		managed_tweens = []
		EVNT.emit_signal("FX_complete")

func start_priority_animation(anim):
	in_priority = true
	yield(anim, "animation_finished")
	in_priority = false
	emit_signal("priority_over")

func get_free_tween():
	var next_tween = null
	if free_tweens.size() == 0:
		next_tween = Tween.new()
		tweens.append(next_tween)
		FXManager.add_child(next_tween)
	else:
		next_tween = free_tweens.pop_back()
	return next_tween


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
