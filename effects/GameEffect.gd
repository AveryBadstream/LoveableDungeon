extends Reference

class_name GameEffect

signal effect_done(effect) #coroutines are confusing :(

const is_action = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var effect_parent
var effect_target
var effect_actor
var step
var steps = []
var effect_hint_mask = EFCT.EffectHint.None
var running = false

func _init(actor, target):
	effect_target = target
	effect_actor = actor

func process_pre_effect_response(effect_response):
	if not effect_response:
		return

func prep():
	return true

func process_post_effect_response(effect_response):
	if not effect_response:
		return

func finish():
	pass

func setup():
	pass

func pre_notify(effect_queue_i):
	process_pre_effect_response(effect_target.effect_pre(self))

func run():
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
