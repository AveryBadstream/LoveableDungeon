extends GameObject

class_name GameActor

export(Array, AI.AIScript) var mob_ai
export(Array, ACT.Actions) var actions


var local_ai = []
var local_actions = {}
var active = false
var acting_state = ACT.ActingState.Wait
var fail_count = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	self.thing_type = ACT.TargetType.TargetActor
	for action_type in ACT.Type:
		local_actions[ACT.Type[action_type]] = []
	if mob_ai.size() > 0:
		for ai_script in mob_ai:
			local_ai.append(AI.AIScriptMapping[ai_script].new(self))
		local_ai.invert()
		assert(local_ai.size() > 0)
	if actions.size() > 0:
		for action in actions:
			var new_action = ACT.ActionMapping[action].new(self)
			local_actions[new_action.action_type].append(new_action)
		for action_type in ACT.Type:
			local_actions[ACT.Type[action_type]].invert()
	 # Replace with function body.
	
func activate():
	acting_state = ACT.ActingState.Act
	if is_player:
		return
	var chosen_ai_script = null
	if local_ai.size() > 0:
		for ai_script in local_ai:
			if ai_script.should_choose():
				chosen_ai_script = ai_script
	if chosen_ai_script:
		chosen_ai_script.run_ai()
	else:
		self.acting_state = ACT.ActingState.Wait
		EVNT.emit_signal("turn_over", self)

func action_impossible(action):
	fail_count += 1
	if fail_count > 50:
		self.action_failed(action)
	else:
		self.activate()

func action_failed(action):
	self.acting_state = ACT.ActingState.Wait
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
