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
		level_label.text = "Level " + str(on_level) + " > " + str(on_level+1)
		show()

func _on_player_ready(player_obj):
	player = player_obj

func _on_MightButton_mouse_entered():
	stat_desc.text = "Might: +5% chance to hit, +1 damage to weapon attacks"

func _on_AgilityButton_mouse_entered():
	stat_desc.text = "Agility: +5% chance to hit, +5% chance to dodge"

func _on_FortitudeButton_mouse_entered():
	stat_desc.text = "Fortitude: +1 hit points per level, +1 stamina, +1 vital burst healing per level"

func _on_StatButton_exited():
	stat_desc.text = ""


func _on_MightButton_pressed():
	hide()
	player.level_up(GameStats.MIGHT)


func _on_AgilityButton_pressed():
	hide()
	player.level_up(GameStats.AGILITY)


func _on_FortitudeButton_pressed():
	hide()
	player.level_up(GameStats.FORTITUDE)
