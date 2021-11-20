tool
extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#Since Godot is "Do repeat yourself" if this is changed all exports with 
# "#FLAG_ACTION_TYPE" need to be updated too.  Really can't wait for this to be
#fixed
enum Type {None = 0, Move = 1, Fly = 2, Phase = 4, Open = 8, Close = 16, Push = 32, Take = 64, Use = 128, Attack = 256, Heal = 512}
const TYPE_FLAGS = "Move,Fly,Phase,Open,Close,Push,Pull,Use,Attack"
var rType = {}
# Called when the node enters the scene tree for the first time.

enum ActionClass {PositionBased, Atomic, TargetBased}

enum ActingState {Wait, Act, Dead}

enum ActionState {Failed, Ready, Acting, Complete, Impossible}

enum ActionResponse {Stop, Impossible, Proceed, Hijacked, Failed, Done, RemoveTarget}

enum ActionPhase {Supports, Can, Pre, Do, Post}

enum TargetHint {None = 0, WholeCellMustSupport = 1, StaminaSpender = 2}

enum TargetType {TargetNone = 0, TargetTile = 1, TargetObject = 2, TargetActor = 4, TargetItem = 8}

enum TargetArea {TargetNone, TargetSingle, TargetCell, TargetCone, TargetWideBeam, TargetSelf}

var TargetAll = 0

func _ready():
	for key in Type.keys():
		rType[Type[key]] = key
	for key in TargetType.keys():
		TargetAll |= TargetType[key]

func TypeKey(val:int):
	return rType[val]

func roll_damage(dam_str, game_stats, extra_stats=[]):
	var damage_tally = 0
	for component in dam_str.split(";"):
		damage_tally += reduce_part(component, game_stats, extra_stats)
	return max(0, damage_tally)

func reduce_part(component, game_stats, extra_stats=[]):
	var d_split = component.split("d")
	var x_split = component.split("x")
	var part = 0
	var part_mult = 1
	if component[0] == "-":
		part_mult = -1
		component = component.substr(1)
	elif component[0] == "+":
		component = component.substr(1)
	if d_split.size() == 2:
		var d_size = reduce_part(d_split[1], game_stats, extra_stats)
		for i in range(reduce_part(d_split[0], game_stats, extra_stats)):
			part += (WRLD.rng.randi() % d_size) + 1
	elif x_split.size() == 2:
		part = reduce_part(x_split[0], game_stats, extra_stats) * reduce_part(x_split[1], game_stats, extra_stats)
	else:
		if component[0] == "s":
			part = game_stats.get_stat(component.split(":")[1])
		else:
			part = component.to_int()
	return part_mult * part

func attack_roll(to_hit, defence):
	return WRLD.rng.randi()%100 < clamp(((70 + (to_hit * 5) ) - (defence * 5)),5,95)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
