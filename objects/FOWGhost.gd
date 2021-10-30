extends Sprite

class_name FOWGhost
# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.
	
func set_mimic(mortal_form: Sprite):
	self.position = mortal_form.position
	self.set_texture(mortal_form.get_texture())
	if mortal_form.is_region():
		self.set_region(true)
		var mfrect = mortal_form.get_region_rect()
		self.set_region_rect(Rect2(mfrect.position, mfrect.size))
	self.set_hframes(mortal_form.get_hframes())
	self.set_vframes(mortal_form.get_vframes())
	self.set_centered(mortal_form.is_centered())
	self.frame = mortal_form.frame

func set_visible(visibility):
	if visibility and self.is_visible():
		self.queue_free()
	.set_visibile(visibility)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
