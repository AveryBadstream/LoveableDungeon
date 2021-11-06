extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum Type {None, Move, Fly, Phase, Open, Close, Push, Pull, Use}
# Called when the node enters the scene tree for the first time.

enum ActionClass {PositionBased, Atomic, TargetBased}

enum ActingState {Wait, Act}

enum ActionState {Failed, Ready, Acting, Complete, Impossible}

enum ActionResponse {Stop, Impossible, Proceed, Hijacked, Failed, Done}

enum ActionPhase {Supports, Can, Pre, Do, Post}

enum TargetHint {None = 0, WholeCellMustSupport = 1}

enum TargetType {TargetNone = 0, TargetTile = 1, TargetObject = 2, TargetActor = 4, TargetItem = 8, TargetAll = 15}

enum TargetArea {TargetSingle, TargetCell}

enum Actions {BasicMove, BasicOpen, BasicClose, Push, BasicUse}


var PreActionMapping = [
	[Actions.BasicMove, "res://actions/BasicMove.gd"],
	[Actions.BasicOpen, "res://actions/BasicOpen.gd"],
	[Actions.BasicClose, "res://actions/BasicClose.gd"],
	[Actions.Push, "res://actions/Push.gd"],
	[Actions.BasicUse, "res://actions/BasicUse.gd"]
]

var ActionMapping = {
	
}
var DummyMove
var DummyFly
var DummyPhase

func _ready():
	for mapping in PreActionMapping:
		ActionMapping[mapping[0]] = load(mapping[1])
	DummyMove = ActionMapping[Actions.BasicMove].new(null)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
