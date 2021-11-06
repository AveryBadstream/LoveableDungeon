extends Node

signal effects_done()

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
enum Type {None, Move, Fly, Phase, Open, Close, Push, Pull, Use}
# Called when the node enters the scene tree for the first time.

enum Effect {Movement, Hostile}

enum ActionState {Failed, Ready, Acting, Complete, Impossible}

enum EffectResponse {Stop, Impossible, Proceed, Hijacked, Failed, Done}

enum EffectPhase {Pre, Do, Post}

enum Effects {Move, Use, Toggle}


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
