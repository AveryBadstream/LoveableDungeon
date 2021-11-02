extends Node2D

signal msg_0(type)
signal log_action(subject, object, action)

onready var DebugSeed = $DebugGui/Hider/Seed
onready var Player = $GameWorld/LevelActors/Player
onready var GameWorld = $GameWorld
onready var TileHighlight = $GameWorld/TileHighlight
onready var LineHighlight = $GameUI/LineHighlight
onready var BlueHighlight = $GameWorld/TileHighlight2
export var random_seed: int
export var use_seed: bool = false

var current_actor = Player

var turn_order = []

var highlight_lines = []

var rng := RandomNumberGenerator.new()
# Called when the node enters the scene tree for the first time.
func _ready():
	if use_seed:
		rng.seed=random_seed
	else:
		rng.randomize()
	DBG.TileHighlight = TileHighlight
	DBG.HighlightGroup = LineHighlight
	DebugSeed.text = "Seed: " + str(rng.seed)
	GameWorld.build(rng)
	WRLD.rng = rng
	connect("msg_0", MSG, "_on_message_0")
	connect("log_action", MSG, "_on_log_action")
	EVNT.subscribe("do_action", self, "_on_do_action")
	EVNT.subscribe("action_complete", self, "_on_action_complete")
	EVNT.subscribe("action_failed", self, "_on_action_failed")
	EVNT.subscribe("action_impossible", self, "_on_action_impossible")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

#func _input(event):
#	if event is InputEventMouseButton:
#		if event.button_index == BUTTON_LEFT and event.pressed:
#			var tilepos = GameWorld.TMap.world_to_map(get_global_mouse_position())
#			if WRLD.world_dimensions and (
#					tilepos.x  < 0 or tilepos.x > WRLD.world_dimensions.x
#					or tilepos.y < 0 or tilepos.y > WRLD.world_dimensions.y):
#						return
#			DBG.clear_highlight()
#			var highlight = highlight_lines.pop_back()
#			while highlight:
#				LineHighlight.remove_child(highlight)
#				highlight.queue_free()
#				highlight = highlight_lines.pop_back()
#			var angle = tilepos.angle_to_point(Player.game_position)
#			for cell in FOV.cast_cone_at(Player.game_position, tilepos, deg2rad(45), 10, GameWorld.fov_block_map):
#				DBG.highlight_cell(cell)
			
#			var oct = FOV.get_octant(Player.game_position, tilepos)
#			for cell in FOV.cast_lerp_line(Player.game_position, tilepos, WRLD.SIGHT_RANGE, GameWorld.fov_block_map):
#				DBG.highlight_cell(cell)
#			for cell in FOV.calc_visible_cells_from(tilepos.x, tilepos.y, WRLD.SIGHT_RANGE, GameWorld.fov_block_map):
#				DBG.highlight_cell(cell)
#			for pos in TIL.interpolated_line(Player.game_position, tilepos):
#				var new_tile = BlueHighlight.duplicate()
#				new_tile.rect_position = pos * 16
#				LineHighlight.add_child(new_tile)
#				highlight_lines.append(new_tile)
			

func _on_world_ready():
	MSG.MessageBox = $CanvasLayer/VBoxContainer/MessageBox
	MSG.LogBox = $CanvasLayer/VBoxContainer/ScrollContainer/LogBox
	WRLD.GameWorld = $GameWorld
	WRLD.TMap = $GameWorld/LoveableBasic
	WRLD.is_ready = true
	EVNT.emit_signal("update_fov")
	turn_order = $GameWorld/LevelActors.get_children()
	current_actor = Player
	Player.activate()

func _on_do_action(action):
	if action.target_type == ACT.TargetType.TargetNone:
		action.finish()
	for target in action.action_targets:
		var target_response = target.can_do_action(action)
		var action_response = action.process_action_response(ACT.ActionPhase.Can, target_response, target)
		if action_response == ACT.ActionResponse.Impossible:
			EVNT.emit_signal("action_impossible", action)
			return
		elif action_response == ACT.ActionResponse.Failed:
			EVNT.emit_signal("action_failed", action)
			return
	for target in action.action_targets:
		var target_response = target.do_action_pre(action)
		var action_response = action.process_action_response(ACT.ActionPhase.Pre, target_response, target)
		if action_response == ACT.ActionResponse.Impossible:
			EVNT.emit_signal("action_impossible", action)
			return
		elif action_response == ACT.ActionResponse.Failed:
			EVNT.emit_signal("action_failed", action)
			return
	for target in action.action_targets:
		var target_response = target.do_action(action)
		var action_response = action.process_action_response(ACT.ActionPhase.Do, target_response, target)
		if action_response == ACT.ActionResponse.Impossible:
			EVNT.emit_signal("action_impossible", action)
			return
		elif action_response == ACT.ActionResponse.Failed:
			EVNT.emit_signal("action_failed", action)
			return
	for target in action.action_targets:
		var target_response = target.do_action_post(action)
		var action_response = action.process_action_response(ACT.ActionPhase.Post, target_response, target)
		if action_response == ACT.ActionResponse.Impossible:
			EVNT.emit_signal("action_impossible", action)
			return
		elif action_response == ACT.ActionResponse.Failed:
			EVNT.emit_signal("action_failed", action)
			return
	action.finish()

func _on_GameWorld_action_failed(actor):
	actor.active() # Replace with function body.


func _on_action_complete(action):
	var current_i = turn_order.find(action.action_actor)
	if current_i + 1 >= turn_order.size():
		current_actor = turn_order[0]
	else:
		current_actor = turn_order[current_i+1]
	current_actor.activate()


func _on_action_failed(action):
	var current_i = turn_order.find(action.action_actor)
	if current_i >= turn_order.size():
		current_actor = turn_order[0]
	else:
		current_actor = turn_order[current_i+1]
	current_actor.activate()


func _on_action_impossible(action):
	current_actor.activate() # Replace with function body.
