extends Reference

class_name GameEffect

signal effect_done(effect) #mostly for actionless effects like toggle
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var effect_action
var effect_target

func _init(action, target):
	effect_action = action
	effect_target = target

func process_effect_response(effect_phase, effect_response, actor):
	if self.has_method("_on_phase_"+EFCT.EffectPhase.keys()[effect_phase]+"_"+EFCT.EffectResponse.keys()[effect_response]):
		return self.call("_on_phase_"+EFCT.EffectPhase.keys()[effect_phase]+"_"+EFCT.EffectResponse.keys()[effect_response], effect_phase, effect_response, actor)
	elif self.has_method("_on_phase_any_"+EFCT.EffectResponse.keys()[effect_response]):
		return self.call("_on_phase_any_"+EFCT.EffectResponse.keys()[effect_response], effect_phase, effect_response, actor)
	elif self.has_method("_on_phase_"+EFCT.EffectPhase.keys()[effect_phase]+"_"+"any"):
		return self.call("_on_phase_"+EFCT.EffectPhase.keys()[effect_phase]+"_"+"any", effect_phase, effect_response, actor)
	else:
		return EFCT.EffectResponse.Proceed

func run_effect():
	return EFCT.EffectResponse.Done

func effect_done():
	effect_action.effect_done(self)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
