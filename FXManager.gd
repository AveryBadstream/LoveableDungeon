extends Node2D

signal priority_over()
# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var puff = preload("res://fx/Puff.tscn")

# Called when the node enters the scene tree for the first time.
func _ready():
	FX.FXManager = self
	EVNT.subscribe("FX_done", self, "_on_FX_done")

func _on_FX_done(FXObject):
	self.remove_child(FXObject)
	FXObject.queue_free()


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
