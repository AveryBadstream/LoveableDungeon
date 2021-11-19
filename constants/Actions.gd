tool
extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

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

func roll_damage(dam_str, game_stats):
	var damage_tally = 0
	for component in dam_str.split(";"):
		var next_part = 0
		var d_split = component.split("d")
		if d_split.size() == 1:
			if component[1] == "s":
				next_part = game_stats.get_stat(component.split(":")[1])
			else:
				next_part = component.substr(1).to_int()
		else:
			for i in range(d_split[0].substr(1).to_int()):
				next_part += WRLD.rng.randi() % d_split[1].to_int()
		if component[0] == "+":
			damage_tally += next_part
		else:
			damage_tally -= next_part
	return max(0, damage_tally)

func attack_roll(to_hit, defence):
	return WRLD.rng.randi()%100 < clamp(((50 + (to_hit * 5) ) - (defence * 5)),5,95)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
