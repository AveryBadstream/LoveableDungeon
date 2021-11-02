extends Node


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
enum SFX {Footstep, Switch, JailBars, Door}

var presounds = {
	SFX.Footstep: "/root/Game/SFX/Footsteps",
	SFX.Switch: "/root/Game/SFX/Switch",
	SFX.JailBars: "/root/Game/SFX/BarsOpen",
	SFX.Door: "/root/Game/SFX/Door",
}

var sounds = {}
# Called when the node enters the scene tree for the first time.
func _ready():
	for sound_id in presounds:
		sounds[sound_id] = get_node(presounds[sound_id])

func play_sound(sound_id: int):
	sounds[sound_id].play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
