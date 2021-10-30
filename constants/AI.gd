extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

enum AIInfoType {LocalAreaAction}

enum AIScript {AimlessWander, PlayerChaser}

var PreAIScriptMapping = [
	[AIScript.AimlessWander, "res://actors/AI/AimlessWander.gd"],
	[AIScript.PlayerChaser, "res://actors/AI/PlayerChaser.gd"],
]

var AIScriptMapping = {
	
}

var is_ready = false
# Called when the node enters the scene tree for the first time.
func _ready():
	for mapping in PreAIScriptMapping:
		AIScriptMapping[mapping[0]] = load(mapping[1])
	 # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
