extends PanelContainer

onready var LevelUpParticles = $VBoxContainer/CharacterSheetButton/LevelUpParticles

var player

func _ready():
	EVNT.subscribe("player_ready", self, "_on_player_ready")
	EVNT.subscribe("player_stats", self, "_on_player_stats")

func _on_player_stats(player):
	if player.experience > 1000:
		LevelUpParticles.emitting = true
	else:
		LevelUpParticles.emitting = false

func _on_player_ready(player_obj):
	player = player_obj

func _on_CharacterSheetButton_pressed():
	if player.experience >= 1000:
		EVNT.emit_signal("show_levelup")


func _on_AgilityButton_focus_entered():
	pass # Replace with function body.


func _on_StatButton_exited():
	pass # Replace with function body.
