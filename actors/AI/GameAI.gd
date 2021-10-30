extends Reference

class_name GameAI
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
# Called when the node enters the scene tree for the first time.
var attached_actor = null

func _ready():
	pass # Replace with function body.

func _init(actor):
	attached_actor = actor

func should_choose():
	return false

func choose_action():
	pass

func run_ai():
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
