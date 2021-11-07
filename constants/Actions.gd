tool
extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum Type {None = 0, Move = 1, Fly = 2, Phase = 4, Open = 8, Close = 16, Push = 32, Pull = 64, Use = 128, Attack = 256}
var rType = {}
# Called when the node enters the scene tree for the first time.

enum ActionClass {PositionBased, Atomic, TargetBased}

enum ActingState {Wait, Act}

enum ActionState {Failed, Ready, Acting, Complete, Impossible}

enum ActionResponse {Stop, Impossible, Proceed, Hijacked, Failed, Done}

enum ActionPhase {Supports, Can, Pre, Do, Post}

enum TargetHint {None = 0, WholeCellMustSupport = 1}

enum TargetType {TargetNone = 0, TargetTile = 1, TargetObject = 2, TargetActor = 4, TargetItem = 8, TargetAll = 15}

enum TargetArea {TargetNone, TargetSingle, TargetCell, TargetCone, TargetWideBeam}

enum Actions {BasicMove, BasicOpen, BasicClose, Push, BasicUse, Wait, Forcewave, RocketteLauncher}


var PreActionMapping = [
	[Actions.BasicMove, "res://actions/action_scripts/BasicMove.gd"],
	[Actions.BasicOpen, "res://actions/action_scripts/BasicOpen.gd"],
	[Actions.BasicClose, "res://actions/action_scripts/BasicClose.gd"],
	[Actions.Push, "res://actions/action_scripts/Push.gd"],
	[Actions.BasicUse, "res://actions/action_scripts/BasicUse.gd"],
	[Actions.Wait, "res://actions/action_scripts/Wait.gd"],
	[Actions.Forcewave, "res://actions/action_scripts/Forcewave.gd"],
	[Actions.RocketteLauncher, "res://actions/action_scripts/RocketteLauncher.gd"]
]

var ActionMapping = {
	
}

func _ready():
	for mapping in PreActionMapping:
		ActionMapping[mapping[0]] = load(mapping[1])
	for key in Type.keys():
		rType[Type[key]] = key

func TypeKey(val:int):
	return rType[val]
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
