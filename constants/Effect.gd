extends Node

enum EffectHint {None = 0, Movement = 1, Interact = 2, Triggered = 4, Forced = 8}

enum EffectResponseType {Stop, Impossible, Proceed, Hijacked, Failed, Done, QueueAfter}

enum EffectPhase {Pre, Do, Post}

enum Effects {Move, Use, Toggle}

class EffectResponse:
	var response_from
	var response_type
	var new_effects = []
	func _init(from, type):
		response_from = from
		response_type = type
	
	func add_effect(effect):
		new_effects.append(effect)

var PreEffectMapping = [
	[Effects.Move, "res://effects/Move.gd"],
	[Effects.Use, "res://effects/Use.gd"],
	[Effects.Toggle, "res://effects/Toggle.gd"],
]

var EffectMapping = {
	
}


var effect_queues = []
var current_queue = 0

var running_effects = 0
var running = false
var prepping = false

func queue_and_run(effect):
	queue_now(effect)
	run_effects()

func queue_now(effect):
	if effect_queues.size() - 1 < current_queue:
		effect_queues.append([])
	if prepping:
		if !effect.prep():
			return
	effect_queues[current_queue].append(effect)
	effect.pre_notify(current_queue)
	if running:
		run_effect_now(effect)

func queue_next(effect):
	if running:
		queue_at_offset(effect, 1)
	else:
		queue_now(effect)

func queue_at_offset(effect, offset):
	var target_queue = current_queue + offset
	while effect_queues.size() - 1 < target_queue:
		effect_queues.append([])
	effect_queues[target_queue].append(effect)
	effect.pre_notify(target_queue)

func replace_in_queue(old_effect, new_effect):
	var found_effect = false
	for queue in effect_queues:
		for i in range(queue):
			if queue[i] == old_effect:
				queue[i] = new_effect
				found_effect = true
				break
		if found_effect:
			break

func multi_queue_now(effects):
	if prepping:
		var effects_to_queue = []
		for effect in effects:
			if effect.prep():
				effects_to_queue.append(effect)
		effects = effects_to_queue
	if effect_queues.size() - 1 < current_queue:
		effect_queues.append([])
	effect_queues[current_queue].append_array(effects)
	for effect in effects:
		effect.pre_notify()
		if running:
			run_effect_now(effect)

func multi_queue_at_offset(effects, offset):
	var target_queue = current_queue + offset
	while effect_queues.size() - 1 < target_queue:
		effect_queues.append([])
	effect_queues[target_queue].append(effects)
	for effect in effects:
		effect.pre_notify(target_queue)

func run_effects():
	if current_queue >= effect_queues.size():
		reset_effect_queues()
		return
	while effect_queues[current_queue].size() == 0 and effect_queues.size() < current_queue + 1:
		current_queue += 1
	var queue_to_run = effect_queues[current_queue]
	var to_remove = []
	prepping = true
	for effect in queue_to_run:
		if effect.prep():
			running_effects += 1
		else:
			to_remove.append(effect)
	for effect in to_remove:
		queue_to_run.erase(effect)
	if effect_queues[current_queue].size() == 0:
		reset_effect_queues()
		return
	prepping = false
	running = true
	for effect in queue_to_run:
		effect.call_deferred("run")

func run_effect_now(effect):
	effect.pre_notify(current_queue)
	if not effect.prep():
		effect_queues[current_queue].erase(effect)
	running_effects += 1
	effect.run()

func pending_effects():
	var total_queued = 0
	if effect_queues.size() > current_queue:
		for i in range(current_queue, effect_queues.size()):
			total_queued += effect_queues[i].size()
	return total_queued

func _on_queue_complete():
	running = false
	for effect in effect_queues[current_queue]:
		effect.finish()
	current_queue += 1
	run_effects()

func reset_effect_queues():
	effect_queues = []
	current_queue = 0
	running_effects = 0
	running = false
	prepping = false
	EVNT.events_done()

func _on_effect_done(effect):
	running_effects -= 1
	if running_effects == 0:
		EVNT.emit_signal("queue_complete")

func _ready():
	for mapping in PreEffectMapping:
		EffectMapping[mapping[0]] = load(mapping[1])
	EVNT.subscribe("effect_done", self, "_on_effect_done")
	EVNT.subscribe("queue_complete", self, "_on_queue_complete")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
