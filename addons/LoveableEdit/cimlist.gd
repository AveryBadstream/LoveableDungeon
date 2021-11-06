tool
extends VBoxContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var cimvalue = $HBoxContainer/cimvalue
onready var showcimlist = $HBoxContainer/showcimlist
onready var full_cimlist = $full_cimlist

# Called when the node enters the scene tree for the first time.
func _ready():
	showcimlist.connect("pressed", self, "_show_full_cimlist") # Replace with function body.
	for key in TIL.CellInteractions.keys():
		full_cimlist.add_item(key)
	full_cimlist.connect("item_selected", self, "_on_item_selected")

func set_cim(cim_value):
	$HBoxContainer/cimvalue.text = str(cim_value)


func _show_full_cimlist():
	if full_cimlist.visible:
		full_cimlist.hide()
	else:
		full_cimlist.show()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
