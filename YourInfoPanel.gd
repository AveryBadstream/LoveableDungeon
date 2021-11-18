extends Panel

onready var HPRect = $VBoxContainer/HBoxContainer2/HPRect
onready var HPLabel = $VBoxContainer/HBoxContainer2/VBoxContainer/HBoxContainer/HPLabel

onready var StaminaRect = $VBoxContainer/HBoxContainer2/StaminaRect
onready var StaminaLabel = $VBoxContainer/HBoxContainer2/VBoxContainer/HBoxContainer/StaminaLabel

func _ready():
	EVNT.subscribe("player_stats", self, "_on_player_stats")

func _on_player_stats(player):
	var cur_hp = player.game_stats.get_resource(GameStats.HP)
	var max_hp = player.game_stats.get_stat(GameStats.HP)
	var cur_sta = player.game_stats.get_resource(GameStats.STAMINA)
	var max_sta = player.game_stats.get_stat(GameStats.STAMINA)
	HPRect.value = round((float(cur_hp) / float(max_hp)) * HPRect.max_value)
	HPLabel.text = "Health\n"+str(cur_hp)+"\n"+str(max_hp)
	StaminaRect.value = round((float(cur_sta) / float(max_sta)) * StaminaRect.max_value)
	StaminaLabel.text = "Stamina\n"+str(cur_sta)+"\n"+str(max_sta)
	
