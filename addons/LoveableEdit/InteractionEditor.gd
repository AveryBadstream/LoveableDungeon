tool
extends GridContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var cim_kvp = []
var act_kvp = []

var edited_object

onready var cim_list = $"CIM Box/ScrollContainer/CIM List"
onready var sam_list = $"Actions Box/ScrollContainer2/Supported Action List"
onready var cim_box = $"CIM Box"
onready var actions_box_button = $"Actions Box/HBoxContainer/Default Action Button"

# Called when the node enters the scene tree for the first time.
func _ready():
	cim_kvp = []
	act_kvp = []
	for key in TIL.CellInteractions.keys():
		if TIL.CellInteractions[key] == 0:
			continue
		var kvp = [key, TIL.CellInteractions[key]]
		var new_checkbox := CheckButton.new()
		new_checkbox.show()
		new_checkbox.text = key
		cim_list.add_child(new_checkbox)
		new_checkbox.show()
		new_checkbox.connect("toggled", self, "recalc_cim_and_update")
		kvp.append(new_checkbox)
		cim_kvp.append(kvp)
		print("Created new checkbox for: "+kvp[0])
	var actions_box = actions_box_button.get_popup()
	actions_box.clear()
	var i = 0
	for key in ACT.Type.keys():
		var kvp = [key, ACT.Type[key]]
		actions_box.add_radio_check_item(key, i)
		if i > 0:
			var new_checkbox := CheckButton.new()
			new_checkbox.show()
			new_checkbox.text = key
			sam_list.add_child(new_checkbox)
			new_checkbox.show()
			new_checkbox.connect("toggled", self, "recalc_sam_and_update")
			kvp.append(new_checkbox)
		act_kvp.append(kvp)
		i += 1
	actions_box.connect("id_pressed", self, "select_default_action")

func select_default_action(action_kvp_id):
	actions_box_button.text = act_kvp[action_kvp_id][0]
	var actions_menu = actions_box_button.get_popup()
	#actions_menu.set_item_checked(action_kvp_id, false)
	change_default_selection(action_kvp_id)
	if edited_object:
		edited_object.default_action = act_kvp[action_kvp_id][1]
		edited_object.property_list_changed_notify()

func focus_object(new_obj):
	if edited_object != new_obj:
		edited_object = new_obj
		update_cim_buttons()
		update_default_action()
		update_sam_buttons()

func update_default_action():
	var kvp_i
	for i in range(act_kvp.size()):
		if act_kvp[i][1] == edited_object.default_action:
			kvp_i = i
	change_default_selection(kvp_i)
	actions_box_button.text = ACT.TypeKey(edited_object.default_action)

func update_cim_buttons():
	var cim = edited_object.cim
	print("CIM is: "+ str(cim))
	for kvp in cim_kvp:
		var mask = kvp[1]
		var cbutton: CheckButton = kvp[2]
		cbutton.disabled = false
		cbutton.set_pressed_no_signal(cim & mask > 0)
		print("cim "+str(kvp[0])+" ("+str(kvp[1])+") is "+ str(cim & mask > 0))

func update_sam_buttons():
	var sam = edited_object.sam
	print("CIM is: "+ str(sam))
	for kvp in act_kvp:
		if kvp[1] == 0:
			continue
		var mask = kvp[1]
		var cbutton: CheckButton = kvp[2]
		cbutton.disabled = false
		cbutton.set_pressed_no_signal(sam & mask > 0)
		print("cim "+str(kvp[0])+" ("+str(kvp[1])+") is "+ str(sam & mask > 0))

func recalc_sam_and_update(_pressed):
	var new_sam = 0
	for kvp in act_kvp:
		if kvp[1] == 0:
			continue
		var cbutton: CheckButton = kvp[2]
		if cbutton.pressed:
			new_sam |= kvp[1]
	edited_object.sam = new_sam
	edited_object.property_list_changed_notify()

func change_default_selection(i):
	var action_menu = actions_box_button.get_popup()
	for i in range(act_kvp.size()):
		action_menu.set_item_checked(i, false)
	action_menu.set_item_checked(i, true)

func recalc_cim_and_update(_pressed):
	var new_cim = 0
	for kvp in cim_kvp:
		var cbutton: CheckButton = kvp[2]
		if cbutton.pressed:
			new_cim |= kvp[1]
	edited_object.cim = new_cim
	edited_object.property_list_changed_notify()
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
