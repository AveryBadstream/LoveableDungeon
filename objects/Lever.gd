extends GameObject


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var toggle_effect = preload("res://effects/Toggle.gd")
onready var animation_player = $AnimationPlayer
# Called when the node enters the scene tree for the first time.
var toggled: bool setget set_toggled, get_toggled
var _toggled = false
# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func effect_pre(effect):
	if effect.effect_hint_mask & EFCT.EffectHint.Interact:
		var response = EFCT.EffectResponse.new(self, EFCT.EffectResponseType.QueueAfter)
		var new_toggle = toggle_effect.new(effect, self, connects_to)
		response.add_effect(new_toggle)
		return response
	return null

func toggle(visibly):
	if visibly:
		FX.start_priority_animation(animation_player)
		if _toggled:
			animation_player.play("On")
		else:
			animation_player.play("Off")
		yield(animation_player, "animation_finished")
	set_toggled(!_toggled)

func set_toggled(is_toggled):
	if _toggled == is_toggled:
		return
	_toggled = is_toggled
	if _toggled:
		frame = 1
	else:
		frame = 0

func get_toggled() -> bool:
	return _toggled
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
