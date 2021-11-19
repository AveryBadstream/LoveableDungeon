extends Sprite

class_name GameObject

signal actor_did_action(actor, object, action_type, success)
signal toggle(myself)
signal position_update_complete()

const is_action = false

export(ACT.Type) var default_action := ACT.Type.Move
export(String) var display_name := "ERROR"
var is_walkable setget set_is_walkable, get_is_walkable
var is_flyable setget set_is_flyable, get_is_flyable
var is_phaseable setget set_is_phaseable, get_is_phaseable
var occupies_cell setget set_occupies_cell, get_occupies_cell
export var is_player := false
var blocks_vision setget set_blocks_vision, get_blocks_vision
var player_remembers setget set_player_remembers, get_player_remembers
export(int) var cim
export(int) var sam
var acting_state = ACT.ActingState.Wait
export(Resource) var game_stats
var last_game_position = position/16
var _game_position = last_game_position
var connects_to = []
var claiming_effects = []
var cell_interaction_mask setget ,get_cim
var my_ghost
var triggers = []
export(ACT.TargetType) var thing_type = ACT.TargetType.TargetObject
var inventory = []
var equipped = {}
const damage_effect = preload("res://effects/TakeDamage.gd")
const die_effect = preload("res://effects/DieEffect.gd")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var game_position: Vector2 setget set_game_position, get_game_position

func set_initial_game_position(at_cell:Vector2):
	position = at_cell * 16
	last_game_position = at_cell
	if game_stats:
		game_stats.initialize()
	if is_player:
		game_stats.connect("stats_changed", self, "_on_stats_changed")
		EVNT.emit_signal("player_stats", self)
	EVNT.emit_signal("update_cimmap", at_cell)

func supports_action(action) -> int:
	var funcname = "_can_support_"+ACT.TypeKey(action.action_type)
	if self.has_method(funcname):
		return self.call(funcname, action)
	elif sam & action.action_type:
		return ACT.ActionResponse.Proceed
	else:
		return ACT.ActionResponse.Stop

func _can_support_Heal(action) -> int:
	if game_stats and game_stats.get_resource(GameStats.HP) < game_stats.get_stat(GameStats.HP):
		return ACT.ActionResponse.Proceed
	return ACT.ActionResponse.RemoveTarget

func effect_pre(effect):
	return null

func effect_post(effect):
	return null

func effect_claim(effect):
	claiming_effects.append(effect)

func effect_release(effect):
	claiming_effects.erase(effect)

func can_do_action(action) -> bool:
	var funcname = "_can_do_"+ACT.TypeKey(action.action_type)
	if self.has_method(funcname):
		return self.call(funcname, action)
	elif sam & action.action_type:
		return ACT.ActionResponse.Proceed
	else:
		return ACT.ActionResponse.Stop

func trigger(trigger_details):
	var funcname = "_trigger_"+ EVNT.TriggerType.keys()[trigger_details.trigger_type]
	if self.has_method(funcname):
		self.call(funcname, trigger_details)
	for ext_trigger in self.triggers:
		if ext_trigger.trigger_type == trigger_details.trigger_type:
			call(ext_trigger.trigger_func_ref, trigger_details)

func do_action_pre(action) -> int:
	var func_name = "_do_action_pre_"+ACT.TypeKey(action.action_type)
	if self.has_method(func_name):
		return self.call(func_name, action)
	elif sam & action.action_type:
		return ACT.ActionResponse.Proceed
	else:
		return ACT.ActionResponse.Stop

func do_action_post(action) -> int:
	if self.has_method("_do_action_post_"+ACT.TypeKey(action.action_type)):
		return self.call("_do_action_post_" + ACT.TypeKey(action.action_type), action)
	elif sam & action.action_type:
		return ACT.ActionResponse.Proceed
	else:
		return ACT.ActionResponse.Stop

func do_action(action) -> int:
	var funcname = "_do_action_"+ACT.TypeKey(action.action_type)
	if self.has_method(funcname):
		return self.call(funcname, action)
	elif sam & action.action_type:
		return ACT.ActionResponse.Proceed
	else:
		return ACT.ActionResponse.Stop

func actor_do_action(actor, action_type:int) -> bool:
	return self.call("_actor_do_" + ACT.TypeKey(action_type), actor)

func get_cim():
	return cim


func hide():
	if get_player_remembers() and !my_ghost:
		var new_ghost = FOWGhost.new()
		new_ghost.set_mimic(self)
		EVNT.emit_signal("create_ghost", new_ghost)
		my_ghost = new_ghost
	.hide()

func show():
	if get_player_remembers() and my_ghost:
		EVNT.emit_signal("end_ghost", my_ghost)
		my_ghost = null
	.show()

func set_game_position(new_position: Vector2, update_real_position=true):
	if new_position != last_game_position and new_position.x > 0 and new_position.y > 0 \
		and new_position.x < WRLD.world_dimensions.x and new_position.y < WRLD.world_dimensions.y:
		if update_real_position:
			self.position = new_position * 16
		var last_last_game_position = last_game_position
		last_game_position = new_position
		EVNT.emit_signal("object_moved", self, last_last_game_position, last_game_position)
	emit_signal("position_update_complete")

func get_game_position() -> Vector2:
	return last_game_position

func set_is_walkable(should_walk):
	var _is_walkable = cim & TIL.CellInteractions.BlocksWalk == 1
	if _is_walkable != should_walk:
		if should_walk:
			cim &= ~(TIL.CellInteractions.BlocksWalk)
		else:
			cim |= TIL.CellInteractions.BlocksWalk
		EVNT.emit_signal("update_cimmap", self.get_game_position())
		
func get_is_walkable():
	return ~(cim & TIL.CellInteractions.BlocksWalk) > 0
	
func set_is_phaseable(should_phase):
	var _is_phaseable = cim & TIL.CellInteractions.BlocksPhase == 0
	if _is_phaseable != should_phase:
		if not should_phase:
			cim |= TIL.CellInteractions.BlocksPhase
		else:
			cim &= ~(TIL.CellInteractions.BlocksPhase)
		EVNT.emit_signal("update_cimmap", self.get_game_position())
		
func get_is_phaseable():
	return ~(cim & TIL.CellInteractions.BlocksPhase) > 0
	
func set_is_flyable(should_fly):
	var _is_flyable = cim & TIL.CellInteractions.BlocksFly == 1
	if _is_flyable != should_fly:
		if not should_fly:
			cim |= TIL.CellInteractions.BlocksFly
		else:
			cim &= ~(TIL.CellInteractions.BlocksFly)
		EVNT.emit_signal("update_cimmap", self.get_game_position())
		
func get_is_flyable():
	return cim & TIL.CellInteractions.BlocksFly == 1
	
func set_occupies_cell(should_occupy):
	var _is_occupying = cim & TIL.CellInteractions.Occupies > 0
	if _is_occupying != should_occupy:
		if should_occupy:
			cim |= TIL.CellInteractions.Occupies
		else:
			cim &= ~(TIL.CellInteractions.Occupies)
		EVNT.emit_signal("update_cimmap", self.get_game_position())
		
func get_occupies_cell():
	return cim & TIL.CellInteractions.Occupies > 0

func set_blocks_vision(should_block):
	var _is_blocking = cim & TIL.CellInteractions.BlocksFOV > 0
	if _is_blocking != should_block:
		if should_block:
			cim |= TIL.CellInteractions.BlocksFOV
		else:
			cim &= ~(TIL.CellInteractions.BlocksFOV)
		EVNT.emit_signal("update_cimmap", self.get_game_position())
		
func get_blocks_vision():
	return cim & TIL.CellInteractions.BlocksFOV > 0

func set_player_remembers(should_remember):
	var _is_remembered = cim & TIL.CellInteractions.PlayerRemembers > 0
	if _is_remembered != should_remember:
		if should_remember:
			cim |= TIL.CellInteractions.PlayerRemembers
		else:
			if my_ghost:
				EVNT.emit_signal("end_ghost", my_ghost)
				my_ghost = null
			cim &= ~(TIL.CellInteractions.PlayerRemembers)
		EVNT.emit_signal("update_cimmap", self.get_game_position())
		
func get_player_remembers():
	return cim & TIL.CellInteractions.PlayerRemembers > 0

func connect_to(target_object):
	self.connects_to.append(target_object)

func _on_toggle(toggled_by):
	pass


func check_adjacent(object):
	return (self.game_position - object.game_position).length() == 1

func effect_done(effect):
	pass

func attack_roll(target):
	if not game_stats or not target.game_stats:
		return false
	var defence = clamp(((50 + (target.game_stats.armor * 5) ) - (self.game_stats.agility * 5)),5,95) 
	return WRLD.rng.randi()%100 < defence

func take_damage(from, damage, type=0):
	if not game_stats:
		return
	game_stats.change_resource(GameStats.HP, -1 * damage)
	EFCT.queue_next(damage_effect.new(from, self, damage, type))
#	if self.game_stats.hp < 0 and not is_player:
#		EVNT.emit_signal("died", self)

func _on_stats_changed():
	EVNT.emit_signal("player_stats", self)

func check_dead():
	if not game_stats:
		return
	if game_stats.get_resource(GameStats.HP) <= 0 and not is_player:
		acting_state = ACT.ActingState.Dead
		EFCT.queue_next(die_effect.new(self))

func resist_effect(stat, penalty):
	if not game_stats:
		return true
	return WRLD.rng.randi() % 100 < 50 + (game_stats.get_stat(stat) * 5) - (penalty * 5)

func get_damage_dealt(_target):
	if not self.game_stats:
		return false
	var damage = (WRLD.rng.randi() % 4) + self.game_stats.might
	return damage
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
