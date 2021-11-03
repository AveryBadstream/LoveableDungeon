extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var puff = preload("res://fx/Puff.tscn")

var FXManager
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func spawn_puff(game_position):
	var new_puff = puff.instance()
	new_puff.position = game_position * 16
	FXManager.add_child(new_puff)
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
