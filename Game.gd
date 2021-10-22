extends Node2D

onready var IndoorBSP = $GameWorld/IndoorBSP
onready var DebugGui = $DebugGui

var rng := RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	rng.randomize()
	IndoorBSP.build_map(null)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_DebugGui_get_leaf_index(i):
	DebugGui.set_index(IndoorBSP.inspect_room)
	DebugGui.highlight_room(IndoorBSP.rooms[IndoorBSP.inspect_room]) # Replace with function body.


func _on_IndoorBSP_build_finished():
	DebugGui.world_ready() # Replace with function body.


func _on_DebugGui_shift_leaf(by):
	IndoorBSP.shift_inspect_room(by)
	DebugGui.highlight_room(IndoorBSP.rooms[IndoorBSP.inspect_room])
