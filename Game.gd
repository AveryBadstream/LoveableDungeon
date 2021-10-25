extends Node2D

signal msg_0(type)
signal log_action(subject, object, action)

onready var IndoorBSP = $GameWorld/IndoorBSP
onready var DebugGui = $GameWorld/IndoorBSP/DebugGui
onready var Player = $GameWorld/LevelActors/Player
onready var GameWorld = $GameWorld
export var random_seed: int
export var use_seed: bool = false

var rng := RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	if use_seed:
		rng.seed=random_seed
	else:
		rng.randomize()
	$GameWorld/IndoorBSP/DebugGui/Hider/Seed.text = "Seed: " + str(rng.seed)
	IndoorBSP.build_map(rng)
	connect("msg_0", MSG, "_on_message_0")
	connect("log_action", MSG, "_on_log_action")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_DebugGui_get_leaf_index(i):
	DebugGui.set_index(IndoorBSP.inspect_room)
	DebugGui.highlight_room(IndoorBSP.rooms[IndoorBSP.inspect_room]) # Replace with function body.


func _on_world_ready():
	MSG.MessageBox = $CanvasLayer/VBoxContainer/MessageBox
	MSG.LogBox = $CanvasLayer/VBoxContainer/ScrollContainer/LogBox
	WRLD.GameWorld = $GameWorld
	WRLD.TMap = $GameWorld/IndoorBSP
	Player.active()


func _on_DebugGui_shift_leaf(by):
	IndoorBSP.shift_inspect_room(by)
	DebugGui.highlight_room(IndoorBSP.rooms[IndoorBSP.inspect_room])


func _on_IndoorBSP_player_start_position(start_pos):
	Player.position = start_pos * 16 # Replace with function body.


func _on_GameWorld_action_failed(actor):
	actor.active() # Replace with function body.


func _on_action_complete(actor, target, action_type):
	emit_signal("log_action", actor, target, action_type)
	actor.active()


func _on_action_failed(actor, target, action_type):
	actor.active()


func _on_action_impossible(actor, target, action_type):
	actor.active() # Replace with function body.
