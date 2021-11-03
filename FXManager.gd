extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var puff = preload("res://fx/Puff.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	FX.FXManager = self # Replace with function body.
	EVNT.subscribe("FX_done", self, "_on_FX_done")

func _on_FX_done(FX):
	self.remove_child(FX)
	FX.queue_free()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
