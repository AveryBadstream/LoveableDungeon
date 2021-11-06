extends Node

signal priority_over()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var puff = preload("res://fx/Puff.tscn")

var in_priority = false

var FXManager
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func spawn_puff(game_position):
	var new_puff = puff.instance()
	new_puff.position = game_position * 16
	FXManager.add_child(new_puff)

func start_priority_animation(anim):
	in_priority = true
	yield(anim, "animation_finished")
	in_priority = false
	emit_signal("priority_over")
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
