extends GameAction


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func set_owned_by(actor):
	self.target_area = ACT.TargetArea.TargetNone
	.set_owned_by(actor)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
