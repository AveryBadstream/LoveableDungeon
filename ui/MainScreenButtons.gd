extends PanelContainer

onready var LevelUpParticles = $VBoxContainer/CharacterSheetButton/LevelUpParticles

func _ready():
	EVNT.subscribe("player_stats", self, "_on_player_stats")

func _on_player_stats(player):
	if player.experience > 1000:
		LevelUpParticles.emitting = true
	else:
		LevelUpParticles.emitting = false
