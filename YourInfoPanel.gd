extends Panel

onready var HPBar = $VBoxContainer/HBoxContainer2/HPBar
onready var HPLabel = $VBoxContainer/HBoxContainer2/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/HPLabel

onready var StaminaBar = $VBoxContainer/HBoxContainer2/StaminaBar
onready var StaminaLabel = $VBoxContainer/HBoxContainer2/VBoxContainer/HBoxContainer/VBoxContainer/HBoxContainer/StaminaLabel

onready var XPBar = $VBoxContainer/HBoxContainer2/VBoxContainer/XPBar
onready var XPLabel = $VBoxContainer/HBoxContainer2/VBoxContainer/HBoxContainer/VBoxContainer/XPLabel

onready var LevelLabel = $VBoxContainer/HBoxContainer2/VBoxContainer/HBoxContainer/VBoxContainer/StatGrid/LevelLabel
onready var ArmorLabel = $VBoxContainer/HBoxContainer2/VBoxContainer/HBoxContainer/VBoxContainer/StatGrid/ArmorLabel
onready var MightLabel = $VBoxContainer/HBoxContainer2/VBoxContainer/HBoxContainer/VBoxContainer/StatGrid/MightLabel
onready var AgilityLabel = $VBoxContainer/HBoxContainer2/VBoxContainer/HBoxContainer/VBoxContainer/StatGrid/AgilityLabel
onready var FortitudeLabel = $VBoxContainer/HBoxContainer2/VBoxContainer/HBoxContainer/VBoxContainer/StatGrid/FortitudeLabel
onready var WizardlynessLabel = $VBoxContainer/HBoxContainer2/VBoxContainer/HBoxContainer/VBoxContainer/StatGrid/WizardlynessLabel

func _ready():
	EVNT.subscribe("player_stats", self, "_on_player_stats")

func _on_player_stats(player):
	var cur_hp = player.game_stats.get_resource(GameStats.HP)
	var max_hp = player.game_stats.get_stat(GameStats.HP)
	var cur_sta = player.game_stats.get_resource(GameStats.STAMINA)
	var max_sta = player.game_stats.get_stat(GameStats.STAMINA)
	HPBar.value = round((float(cur_hp) / float(max_hp)) * HPBar.max_value)
	HPLabel.text = "Health\n"+str(cur_hp)+"\n"+str(max_hp)
	StaminaBar.value = round((float(cur_sta) / float(max_sta)) * StaminaBar.max_value)
	StaminaLabel.text = "Stamina\n"+str(cur_sta)+"\n"+str(max_sta)
	XPBar.value = round(float(player.experience)/float(1000) * XPBar.max_value)
	XPLabel.text = "%5d/1000" % player.experience
	LevelLabel.text =     "Level: %3d"%player.game_stats.get_stat(GameStats.LEVEL)
	ArmorLabel.text =     "Armor: %3d"%player.game_stats.get_stat(GameStats.ARMOR)
	MightLabel.text =     "Might: %3d"%player.game_stats.get_stat(GameStats.MIGHT)
	AgilityLabel.text =   "Agility: %3d"%player.game_stats.get_stat(GameStats.AGILITY)
	FortitudeLabel.text =        "Fortitude: %3d"%player.game_stats.get_stat(GameStats.FORTITUDE)
	var wiz = player.game_stats.get_stat(GameStats.WIZARDLYNESS)
	WizardlynessLabel.clear()
	if wiz > 0:
		WizardlynessLabel.append_bbcode("Wizardlyness: %3d"%wiz)
	else:
		WizardlynessLabel.clear()
	
