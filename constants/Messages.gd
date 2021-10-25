extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var MessageBox: Label = null
var LogBox: RichTextLabel = null

var first_party_log_color = "blue"
var third_party_log_color = "red"

var full_log = []

#Non-log messages

#0-arity message types
enum MsgType {Clear, Open, Close, NoMove}
#Non-logged message-string mappings

#0-arity messages
var Msg0Str = {
	MsgType.Clear: "",
	MsgType.Open: "Open in which direction?",
	MsgType.Close: "Close in which direction?",
	MsgType.NoMove: "You bump into something"
}

#2-arity messages
#special format variables:

#2-arity logged messages
#special format variables:
#subject: first argument to message_2, the thing doing the action
#object: second argument to message_22
#pt3ps: present-tense-third-party-s, for when a verb needs the third party present tense based of if actor: is first party
#
var LogActionStr = {
	ACT.Type.Open: "[color={log_color}]{subject} open{pt3ps} the {object}[/color]",
	ACT.Type.Close: "[color={log_color}]{subject} close{pt3ps} the {object}[/color]"
}

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

func _on_message_0(type):
	if Msg0Str.has(type):
		MessageBox.text = Msg0Str[type]
		
func _on_log_action(subject, object, action):
	if LogActionStr.keys().has(action):
		var format_dict = {
				"pt3ps": "" if subject.is_player else "s",
				"subject": subject.display_name,
				"object": object.display_name,
				"log_color": first_party_log_color if subject.is_player else third_party_log_color
		}
		add_log(LogActionStr[action].format(format_dict))

func add_log(msg):
	full_log.append(msg)
	LogBox.clear()
	for log_message in full_log.slice(max(full_log.size() - 7, 0), full_log.size() - 1):
		LogBox.append_bbcode(log_message)
		LogBox.newline()

func direction_to_string(direction: Vector2):
	if direction == Vector2.UP:
		return "north"
	elif direction == Vector2.DOWN:
		return "south"
	elif direction == Vector2.LEFT:
		return "left"
	elif direction == Vector2.RIGHT:
		return "right"
