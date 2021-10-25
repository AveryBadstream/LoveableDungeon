extends GameActor


signal message_0(msg)
signal try_action_at(actor, action, action_position)

enum ActionState {Act, Wait}
var opens_doors = true
var action_state = ActionState.Wait
var pending_action = ACT.Type.None
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
func _input(event):
	if !event.is_pressed() or !(action_state == ActionState.Act):
		return
	if event.is_action("move_left"):
		act_in_direction(Vector2.LEFT)
	elif event.is_action("move_right"):
		act_in_direction(Vector2.RIGHT)
	elif event.is_action("move_up"):
		act_in_direction(Vector2.UP)
	elif event.is_action("move_down"):
		act_in_direction(Vector2.DOWN)
	elif event.is_action("open"):
		emit_signal("message_0", MSG.MsgType.Open)
		pending_action = ACT.Type.Open
	elif event.is_action("close"):
		emit_signal("message_0", MSG.MsgType.Close)
		pending_action = ACT.Type.Close

func act_in_direction(dir: Vector2):
	emit_signal("try_action_at", self, self.game_position + dir, pending_action)
# Called when the node enters the scene tree for the first time.
func _ready():
	connect("message_0", MSG, "_on_message_0") # Replace with function body.

func active():
	action_state = ActionState.Act
	pending_action = ACT.Type.None

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
