extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var MessageBox: Label = null
var LogBox: RichTextLabel = null

var first_party_log_color = "teal"
var third_party_log_color = "maroon"

var full_log = []

func action_message(action, msg, format_info=[]):
	for format_part in format_info:
		pass
	var format_dict = {
			"pt3ps": "" if action.action_actor.is_player else "s",
			"subject": ("" if action.action_actor.is_player else "the ")+action.action_actor.display_name,
			"log_color": first_party_log_color if action.action_actor.is_player else third_party_log_color
	}
	format_dict["object"] = ("" if action.action_targets[0].is_player else "the ")+action.action_targets[0].display_name if action.action_targets.size() > 0 else ""
	MessageBox.text = msg.format(format_dict)

func action_log(action, msg, format_info=[]):
	for format_part in format_info:
		pass
	msg = "[color={log_color}]"+msg+"[/color]"
	var format_dict = {
			"pt3ps": "" if action.action_actor.is_player else "s",
			"subject": ("" if action.action_actor.is_player else "the ")+action.action_actor.display_name,
			"log_color": first_party_log_color if action.action_actor.is_player else third_party_log_color
	}
	format_dict["object"] = ("" if action.action_targets[0].is_player else "the ")+action.action_targets[0].display_name if action.action_targets.size() >0 else ""
	add_log(msg.format(format_dict))

func effect_log(effect, msg, extra_dict={}):
	msg = "[color={log_color}]"+msg+"[/color]"
	var format_dict = {
			"pt3ps": "" if effect.effect_actor.is_player else "s",
			"spos": "r" if effect.effect_actor.is_player else "'s",
			"opos": "r" if effect.effect_actor.is_player else "'s",
			"subject": ("" if effect.effect_actor.is_player else "the ")+effect.effect_actor.display_name,
			"object": ("" if effect.effect_target.is_player else "the ")+effect.effect_target.display_name,
			"log_color": first_party_log_color if effect.effect_actor.is_player else third_party_log_color
	}
	for key in extra_dict.keys():
		if key == "third_party":
			format_dict[key] = ("" if extra_dict[key].is_player else "the ")+extra_dict[key].display_name
		else:
			format_dict[key] = extra_dict[key]
	add_log(msg.format(format_dict))

func game_log(msg):
	add_log(msg)

func add_log(msg):
	full_log.append(msg)
	LogBox.clear()
	print(msg)
	for log_message in full_log.slice(max(full_log.size() - 30, 0), full_log.size() - 1):
		LogBox.newline()
		LogBox.append_bbcode(log_message)
		LogBox.scroll_to_line(LogBox.get_line_count()-1)


func direction_to_string(direction: Vector2):
	if direction == Vector2.UP:
		return "north"
	elif direction == Vector2.DOWN:
		return "south"
	elif direction == Vector2.LEFT:
		return "left"
	elif direction == Vector2.RIGHT:
		return "right"
