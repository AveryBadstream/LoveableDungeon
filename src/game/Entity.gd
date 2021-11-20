extends Sprite

#flags for various cell interactions used in FOV casting
#FLAG_CELL_INTERACTION
export(int, FLAGS, "Blocks FOV", "Blocks Walking", "Blocks Flying", "Blocks Phasing", "Occupies", "Player Remembers", "Immovable") var interactions = 30
#Supported actions
#FLAG_ACTION_TYPE
export(int, FLAGS, "Move", "Fly", "Phase", "Open", "Close", "Push", "Take", "Use", "Attack", "Heal") var supported_actions
#whether this is a player or not
export(bool) var is_player = false

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
