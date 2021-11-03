extends GameObject


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var opened:bool setget set_opened, get_opened
var _opened = false
var open_effect = preload("res://effects/Open.gd")
var close_effect = preload("res://effects/Close.gd")
onready var animation_player = $AnimationPlayer
# Called when the node enters the scene tree for the first time.

func effect_pre(effect):
	if effect.effect_hint_mask & (EFCT.EffectHint.Interact & EFCT.EffectHint.Triggered):
		var response = EFCT.EffectResponse.new(self, EFCT.EffectResponseType.QueueAfter)
		var new_effect
		if _opened:
			new_effect = close_effect.new(effect, self, self)
		else:
			new_effect = open_effect.new(effect, self, self)
		response.add_effect(new_effect)
		return response
	return null

func _can_support_Move(action):
	return _opened

func _can_support_Open(action):
	return !_opened

func _can_support_Close(action):
	return _opened

func open(visibly:bool):
	if _opened:
		return
	if visibly:
		animation_player.play("Open")
		yield(animation_player, "animation_finished")
	set_opened(true)

func close(visibly:bool):
	if !_opened:
		return
	if visibly:
		animation_player.play("Close")
		yield(animation_player, "animation_finished")
	set_opened(false)

func toggle(visibly:bool):
	if _opened:
		close(visibly)
	else:
		close(visibly)

func set_opened(is_open:bool):
	if is_open == _opened:
		return
	_opened = is_open
	if _opened:
		default_action = ACT.Type.Move
		frame = 1
	else:
		default_action = ACT.Type.Open
		frame = 0
	self.set_blocks_vision(!_opened)

func get_opened()->bool:
	return _opened

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
