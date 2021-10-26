extends Node2D

signal msg_0(type)
signal log_action(subject, object, action)

onready var DebugSeed = $DebugGui/Hider/Seed
onready var Player = $GameWorld/LevelActors/Player
onready var GameWorld = $GameWorld
onready var TileHighlight = $GameWorld/TileHighlight
onready var LineHighlight = $GameUI/LineHighlight
export var random_seed: int
export var use_seed: bool = false

var highlight_lines = []

var rng := RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	if use_seed:
		rng.seed=random_seed
	else:
		rng.randomize()
	DebugSeed.text = "Seed: " + str(rng.seed)
	GameWorld.build(rng)
	connect("msg_0", MSG, "_on_message_0")
	connect("log_action", MSG, "_on_log_action")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_LEFT and event.pressed:
			var tilepos = GameWorld.TMap.world_to_map(get_global_mouse_position())
			if WRLD.world_dimensions and (
					tilepos.x  < 0 or tilepos.x > WRLD.world_dimensions.x
					or tilepos.y < 0 or tilepos.y > WRLD.world_dimensions.y):
						return
			var highlight = highlight_lines.pop_back()
			while highlight:
				LineHighlight.remove_child(highlight)
				highlight.queue_free()
				highlight = highlight_lines.pop_back()
			for pos in TIL.get_bres_line(Player.game_position, tilepos, GameWorld.fov_block_map):
				var new_tile = TileHighlight.duplicate()
				new_tile.rect_position = pos * 16
				LineHighlight.add_child(new_tile)
				highlight_lines.append(new_tile)
			

func _on_world_ready():
	MSG.MessageBox = $CanvasLayer/VBoxContainer/MessageBox
	MSG.LogBox = $CanvasLayer/VBoxContainer/ScrollContainer/LogBox
	WRLD.GameWorld = $GameWorld
	WRLD.TMap = $GameWorld/LoveableBasic
	GameWorld.update_fov(Player.game_position)
	Player.active()


func _on_GameWorld_action_failed(actor):
	actor.active() # Replace with function body.


func _on_action_complete(actor, target, action_type):
	emit_signal("log_action", actor, target, action_type)
	if actor.is_player and action_type == ACT.Type.Move:
		GameWorld.update_fov(actor.game_position)
	actor.active()


func _on_action_failed(actor, target, action_type):
	actor.active()


func _on_action_impossible(actor, target, action_type):
	actor.active() # Replace with function body.
