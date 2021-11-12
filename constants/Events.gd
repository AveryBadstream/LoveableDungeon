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
signal world_ready()
#Visibility management
signal update_visible_map(position, should_block)

#Object ghost information
signal create_ghost(ghost)
signal end_ghost(ghost)

#Round and turn information
signal round_over()
signal turn_over()

#Action signals
signal try_action_at(action_type, actor, position)

signal do_action(action)

signal action_impossible(action)
signal action_failed(action)
signal action_complete(action)

#Effect signals
signal effect_done(effect)
signal all_effects_done()
signal queue_complete()

#Game effect signals
signal slammed(thing, into, from, to)

#Map management signals
signal update_fov()
signal begin_fov()
signal update_fov_cell(cell)
signal fov_cell_updated(cell)
signal object_moved(object, from_position)
signal update_cimmap(at_cell)
signal end_fov()

#AI Signals
signal ai_request_info(actor, ai_info_type, extra_info)

#FX Signals
signal FX_done(FX)

#UI Targetting Hint Signals
signal hint_area_cone(from, radius, width)
signal hint_area_none()
signal hint_action(action)
# Called when the node enters the scene tree for the first time.

enum TriggerType {Connection, MovedTo, EndedMovement, SlammedInto }


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

func events_done():
	emit_signal("all_effects_done")

func trigger_Connection(from, to):
	to.trigger({"triggered_by": from, "trigger_type": TriggerType.Connection})

func trigger_MovedTo(thing, triggered_thing, from_cell, to_cell):
	triggered_thing.trigger({"triggered_by": thing, \
							"trigger_type": TriggerType.MovedTo, \
							"from_cell": from_cell, "to_cell": to_cell})

func trigger_EndedMovement(thing, triggered_thing, from_cell, to_cell):
	triggered_thing.trigger({"triggered_by": thing, \
							"trigger_type": TriggerType.EndedMovement, \
							"from_cell": from_cell, "to_cell": to_cell})

func trigger_SlammedInto(thing, triggered_thing, from_cell, to_cell):
	triggered_thing.trigger({"triggered_by": thing, \
							"trigger_type": TriggerType.SlammedInto, \
							"from_cell": from_cell, "to_cell": to_cell})

func trigger_SlammedAt(thing, triggered_thing, from_cell, to_cell):
	triggered_thing.trigger({"triggered_by": thing, \
							"trigger_type": TriggerType.SlammedAt, \
							"from_cell": from_cell, "to_cell": to_cell})
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
