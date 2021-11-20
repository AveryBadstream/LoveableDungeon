extends Panel


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var statup = $StatUp
onready var level_label = $StatUp/VBoxContainer/LevelLabel
onready var stat_desc = $StatUp/VBoxContainer/StatDesc

var player
var on_level

# Called when the node enters the scene tree for the first time.
func _ready():
	EVNT.subscribe("player_ready", self, "_on_player_ready")
	EVNT.subscribe("show_levelup", self, "_on_show_levelup")

func _on_show_levelup():
	if player.experience < 1000:
		hide()
	else:
		on_level = player.game_stats.get_stat(GameStats.LEVEL)
		level_label.text = "Level " + str(on_level) + " to Level " + str(on_level+1)
		show()

func _on_player_ready(player_obj):
	player = player_obj

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_MightButton_mouse_entered():
	stat_desc.text = "Might: +5 percent chance to hit, +1 damage to weapon attacks"

func _on_AgilityButton_mouse_entered():
	stat_desc.text = "Agility: +5 percent chance to hit, +5 percent chance to dodge"

func _on_FortitudeButton_mouse_entered():
	stat_desc.text = "Fortitude: +1 hit points, +1 stamina, +1 vital burst healing"

func _on_StatButton_exited():
	stat_desc.text = ""
