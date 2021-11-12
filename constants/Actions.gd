tool
extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum Type {None = 0, Move = 1, Fly = 2, Phase = 4, Open = 8, Close = 16, Push = 32, Pull = 64, Use = 128, Attack = 256}
const TYPE_FLAGS = "Move,Fly,Phase,Open,Close,Push,Pull,Use,Attack"
var rType = {}
# Called when the node enters the scene tree for the first time.

enum ActionClass {PositionBased, Atomic, TargetBased}

enum ActingState {Wait, Act}

enum ActionState {Failed, Ready, Acting, Complete, Impossible}

enum ActionResponse {Stop, Impossible, Proceed, Hijacked, Failed, Done}

enum ActionPhase {Supports, Can, Pre, Do, Post}

enum TargetHint {None = 0, WholeCellMustSupport = 1}

enum TargetType {TargetNone = 0, TargetTile = 1, TargetObject = 2, TargetActor = 4, TargetItem = 8}

enum TargetArea {TargetNone, TargetSingle, TargetCell, TargetCone, TargetWideBeam}

enum Actions {BasicMove, BasicOpen, BasicClose, Push, BasicUse, Wait, Forcewave, RocketteLauncher}

var TargetAll = 0

func _ready():
	for key in Type.keys():
		rType[Type[key]] = key
	for key in TargetType.keys():
		TargetAll |= TargetType[key]

func TypeKey(val:int):
	return rType[val]
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
