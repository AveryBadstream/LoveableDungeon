extends Node2D

signal action_complete(actor, target, action_type)
signal action_failed(actor, target, action_type)
signal action_impossible(actor, target, action_type)
signal message_0(msg)
signal log_2(msg, subject, object)

onready var TMap = $LoveableBasic
onready var LevelObjects = $LevelObjects
var LevelGenerator = preload("res://map/Generators/basic_levelgen.tres")

const Door = preload("res://objects/Door.tscn")
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func try_move(actor, direction):
	if TMap.is_tile_walkable(actor.game_position.x, actor.game_position.y):
		return

# Called when the node enters the scene tree for the first time.
func _ready():
	.connect("message_0", MSG, "_on_message_0")
	.connect("log_2", MSG, "_on_log_2")
	var generator = LevelGenerator.new()
	generator.connect("build_finished", TMap, "_on_build_finished")
	generator.connect("place_door", self, "_on_place_door")


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func actor_do_action_to(actor, action, subject):
	if !actor.actions_available.has(action):
		emit_signal("action_impossible", actor, subject, action)
		return
	elif !subject.can_actor_do_action(actor, action):
		emit_signal("action_failed", actor, subject, action)
		return
	else:
		subject.actor_do_action(actor, action)
		emit_signal("action_complete", actor, subject, action)
		return

func _on_actor_try_action_at(actor, target_position, action = null):
	var target_thing = thing_at_position(target_position)
	if !target_thing or ((action == ACT.Type.Move or (action == ACT.Type.None and target_thing.default_action == ACT.Type.Move)) and target_thing.is_walkable):
		if (action == ACT.Type.Move or action == ACT.Type.None) and TMap.is_tile_walkable(target_position):
			actor.game_position = target_position # Replace with function body.
			emit_signal("action_complete", actor, null, ACT.Type.Move)
			return
		else:
			emit_signal("action_failed", actor, null, ACT.Type.Move)
			return
	else:
		emit_signal("action_failed", actor, null, null)
	actor_do_action_to(actor, target_thing.default_action if action == ACT.Type.None else action, target_thing)

func _on_place_door(position):
	var new_door = Door.instance()
	new_door.game_position = position
	LevelObjects.add_child(new_door)

func object_at_position(position):
	for object in LevelObjects.get_children():
		if object.game_position == position:
			return object
	return null

func actor_at_position(position):
	for actor in LevelObjects.get_children():
		if actor.game_position == position:
			return actor
	return null

func thing_at_position(position, prefer_actor=true):
	var found_actor = actor_at_position(position)
	if prefer_actor and found_actor:
		return found_actor
	var found_object = object_at_position(position)
	return found_object if found_object else found_actor
	
