extends Node

signal effects_done()

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

var queued_effects = 0
var delayed_effects = []

func queue_effect(effect):
	queued_effects += 1

func queue_delayed(effect):
	delayed_effects.append(effect)

func effect_done(effect):
	queued_effects -= 1
	if queued_effects == 0:
		if delayed_effects.size() > 0:
			for effect in delayed_effects:
				EVNT.publish_effect(effect)
			delayed_effects = []
		emit_signal("effects_done")



func _ready():
	for mapping in PreEffectMapping:
		EffectMapping[mapping[0]] = load(mapping[1])
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
