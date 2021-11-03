extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
#World building signals
signal update_room_count(room_count)
signal update_current_room(current_room)
signal build_finished(tiles)
signal mst_build(path_zones)
signal export_generator_config(conf_type, conf_value)
signal place_thing(thing_type, thing_index, at_cell)
signal remove_thing(thing_type, thing_index, at_cell)
signal connect_things(from_thing_type, from_thing_index, from_thing_cell, to_thing_type, to_thing_index, to_thing_cell)
signal player_start_position(start_pos)
#Visibility management
signal update_visible_map(position, should_block)

#Object ghost information
signal create_ghost(ghost)
signal end_ghost(ghost)

#Round and turn information
signal round_over()
signal turn_over(actor)

#Action signals
signal try_action_at(action_type, actor, position)

signal do_action(action)

signal action_impossible(action)
signal action_failed(action)
signal action_complete(action)

#Effect signals
signal do_effect(effect)

#FOV calculations
signal update_fov()
signal begin_fov()
signal update_fov_cell(cell)
signal object_moved(object, from_position)
signal end_fov()

#AI Signals
signal ai_request_info(actor, ai_info_type, extra_info)

#FX Signals
signal FX_done(FX)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func subscribe(signal_name, target, target_method):
	connect(signal_name, target, target_method)

func publish_action(action):
	emit_signal("do_action", action)

func publish_effect(effect):
	emit_signal("do_effect", effect)

func emit_action(who, action_array):
	if action_array[0] == ACT.Type.None:
		emit_signal("turn_over")
	var action_class = ACT.action_class_map[action_array[0]]
	if action_class == ACT.ActionClass.PositionBased:
		emit_signal("try_action_at", who, action_array[1], action_array[0])
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
