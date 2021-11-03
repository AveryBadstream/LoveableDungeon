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
var after_queue = []
var effect_hint_mask = EFCT.EffectHint.None
var running = false

func _init(parent, actor, target):
	effect_parent = parent
	effect_target = target
	effect_actor = actor

func process_pre_effect_response(effect_response):
	if not effect_response:
		return
	elif effect_response.response_type == EFCT.EffectResponseType.QueueAfter:
		for next_effect in effect_response.new_effects:
			after_queue.append(next_effect)

func process_post_effect_response(effect_response):
	if not effect_response:
		return

func setup():
	pass

func pre_notify():
	process_pre_effect_response(effect_target.effect_pre(self))

func post_notify():
	process_post_effect_response(effect_target.effect_post(self))

func process_after_queue():
	for effect in after_queue:
		EVNT.publish_effect(effect)

func do_effect():
	run_effect()
	process_after_queue()
	while running:
		yield(self, "effect_done")
		run_effect()
		process_after_queue()
	effect_after()

func run_effect():
	pass

func effect_done(effect):
	if after_queue.has(effect):
		after_queue.erase(effect)
		effect_after()

func effect_after():
	if after_queue.size() == 0 and not running and steps.size() == 0:
		effect_parent.effect_done(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
