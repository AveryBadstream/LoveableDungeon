extends Node2D

signal msg_0(type)
signal log_action(subject, object, action)

const player_scene = preload("res://Player.tscn")

onready var GameWorld = $GameWorld
onready var LevelActors = $GameWorld/WorldView/LevelActors
onready var OnlyTween = $Tweens/Tween
onready var GameUI = $GameUI
onready var OverlayTiles = $GameWorld/OverlayWorld/OverlayTiles
#onready var Camerah = $PlayerCamera
export var random_seed: int
export var use_seed: bool = false

var dead_queue = []

var Player

var current_actor

var turn_order = []

var highlight_lines = []

var rng := RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	if use_seed:
		rng.seed=random_seed
	else:
		rng.randomize()
	Player = player_scene.instance()
	GameWorld.Player = Player
	current_actor = Player
	EVNT.subscribe("world_ready", self, "_on_world_ready")
	GameWorld.build(rng)
	WRLD.rng = rng
	WRLD.tween = OnlyTween
	EVNT.subscribe("do_action", self, "_on_do_action")
	EVNT.subscribe("action_complete", self, "_on_action_complete")
	EVNT.subscribe("action_failed", self, "_on_action_failed")
	EVNT.subscribe("action_impossible", self, "_on_action_impossible")
	EVNT.subscribe("turn_over", self, "_on_turn_over")
	EVNT.subscribe("died", self, "_on_died")

func _on_world_ready():
	WRLD.set_game_world($GameWorld)
	WRLD.GameWorld = $GameWorld
	WRLD.TMap = $GameWorld/WorldView/WorldTiles
	WRLD.is_ready = true
	EVNT.emit_signal("update_fov")
	turn_order = $GameWorld/LevelActors.get_children()
	current_actor = Player
	#remove_child(Camerah)
	#Player.add_child(Camerah)
	#Camerah.global_position = Player.global_position
	GameUI.OverlayTiles = OverlayTiles
	GameUI.pause_mode = Node.PAUSE_MODE_PROCESS
	Player.activate()

func _on_do_action(action):
	if action.target_type == ACT.TargetType.TargetNone:
		action.finish()
	var ignore_targets = []
	for target in action.action_targets:
		var target_response = target.can_do_action(action)
		var action_response = action.process_action_response(ACT.ActionPhase.Can, target_response, target)
		if action_response == ACT.ActionResponse.Impossible:
			EVNT.emit_signal("action_impossible", action)
			return
		elif action_response == ACT.ActionResponse.Failed:
			EVNT.emit_signal("action_failed", action)
			return
		elif action_response == ACT.ActionResponse.RemoveTarget:
			ignore_targets.append(target)
	for target in ignore_targets:
		action.action_targets.erase(target)
	action.execute()

func _on_action_complete(action):
	EFCT.run_effects()
	yield(EVNT, "all_effects_done")
	GameWorld.step_end()
	while EFCT.pending_effects() > 0:
		EFCT.run_effects()
		yield(EVNT, "all_effects_done")
		GameWorld.step_end()
	EVNT.emit_signal("turn_over")

func _on_turn_over():
	for thing in dead_queue:
		GameWorld.remove_object(thing)
	dead_queue = []
	var next_actor = next_actor(current_actor)
	while not is_instance_valid(next_actor) or next_actor.acting_state == ACT.ActingState.Dead:
		next_actor = next_actor(next_actor)
	current_actor = next_actor
	current_actor.call_deferred("activate")

func next_actor(actor):
	var current_i = actor.get_index()
	if current_i + 1 >= LevelActors.get_child_count():
		return LevelActors.get_child(0)
	else:
		return LevelActors.get_child(current_i+1)

func _on_died(thing):
	dead_queue.append(thing)
	if thing.game_stats:
		Player.gain_experience(thing.game_stats.level)

func _on_action_failed(action):
	_on_turn_over()

func _on_action_impossible(action):
	_on_turn_over() # Replace with function body.


func _on_StatButton_exited():
	pass # Replace with function body.
