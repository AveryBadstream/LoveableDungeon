tool
extends TabContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var cim_kvp = []
var edited_object

onready var cim_list = $"InteractionEditor/CIM Box/ScrollContainer/CIM List"

# Called when the node enters the scene tree for the first time.
func _ready():
	for key in TIL.CellInteractions.keys():
		cim_kvp.append([key, TIL.CellInteractions[key]])
	for kvp in cim_kvp:
		if kvp[1] == 0:
			continue
		var new_checkbox := CheckButton.new()
		new_checkbox.show()
		new_checkbox.text = kvp[0]
		kvp.append(new_checkbox)
		cim_list.add_child(new_checkbox)
		new_checkbox.show()
		new_checkbox.connect("toggled", self, "recalc_cim_and_update")
		print("Created new checkbox for: "+kvp[0])
	set_tab_title(0, "Interactions")

func focus_object(new_obj):
	if edited_object != new_obj:
		edited_object = new_obj
		if "cim" in new_obj:
			update_cim_buttons(new_obj)

func update_cim_buttons(from_obj):
	var cim = from_obj.cim
	print("CIM is: "+ str(cim))
	for kvp in cim_kvp:
		if kvp[1] == 0:
			continue
		var mask = kvp[1]
		var cbutton: CheckButton = kvp[2]
		cbutton.set_pressed_no_signal(cim & mask > 0)
		print("cim "+str(kvp[0])+" ("+str(kvp[1])+") is "+ str(cim & mask > 0))

func recalc_cim_and_update(obj):
	var new_cim = 0
	for kvp in cim_kvp:
		if kvp[1] == 0:
			continue
		var cbutton: CheckButton = kvp[2]
		if cbutton.pressed:
			new_cim |= kvp[1]
	edited_object.cim = new_cim
	edited_object.property_list_changed_notify()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
