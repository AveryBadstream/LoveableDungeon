extends GameObject

class_name GameActor

export(Array, Resource) var mob_ai
export(Array, Resource) var actions
export(Dictionary) var default_actions


var local_ai = []
var local_actions = []
var local_default_actions = {}
var active = false
var fail_count = 0
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	self.thing_type = ACT.TargetType.TargetActor
	if mob_ai.size() > 0:
		for ai_script in mob_ai:
			var new_script = ai_script.duplicate()
			new_script.attach(self)
			local_ai.append(new_script)
		local_ai.invert()
		assert(local_ai.size() > 0)
	own_fucking_actions()

func own_fucking_actions(): #fuck this dogshit inconsistent game engine to hell
	for key in default_actions.keys():
		self.local_default_actions[key] = self.default_actions[key].duplicate(true)
		self.local_default_actions[key].set_owned_by(self)
	for action in actions:
		var new_local = action.duplicate(true)
		self.local_actions.append(new_local)
		new_local.set_owned_by(self)
	 # Replace with function body.
	
func activate():
	self.acting_state = ACT.ActingState.Act
	var chosen_ai_script = null
	if local_ai.size() > 0:
		for ai_script in local_ai:
			if ai_script.should_choose():
				chosen_ai_script = ai_script
	if chosen_ai_script:
		chosen_ai_script.choose_action()
		chosen_ai_script.run_ai()
	else:
		self.acting_state = ACT.ActingState.Wait
		EVNT.emit_signal("turn_over")

func action_impossible(action):
	fail_count += 1
	if fail_count > 50:
		self.action_failed(action)
	else:
		self.activate()

func action_failed(_action):
	self.acting_state = ACT.ActingState.Wait

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
