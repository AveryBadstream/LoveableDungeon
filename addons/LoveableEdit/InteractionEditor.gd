tool
extends GridContainer


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var cim_kvp = []
var act_kvp = []

var edited_object
var editor_icons

onready var cim_list = $"CIM Box/ScrollContainer/CIM List"
onready var sam_list = $"Actions Box/ScrollContainer2/Supported Action List"
onready var cim_box = $"CIM Box"
onready var actions_box_button = $"Actions Box/HBoxContainer/Default Action Button"

onready var max_hp_box = $OtherStats/GameStats/Fields/MaxHPBox
onready var might_box = $OtherStats/GameStats/Fields/MightBox
onready var agility_box = $OtherStats/GameStats/Fields/AgilityBox
onready var stamina_box = $OtherStats/GameStats/Fields/StaminaBox
onready var armor_box = $OtherStats/GameStats/Fields/ArmorBox
onready var name_entry = $OtherStats/OtherInformation/Fields/NameEdit
onready var is_player_check = $OtherStats/OtherInformation/Fields/IsPlayerCheck
# Called when the node enters the scene tree for the first time.
func _ready():
	cim_kvp = []
	act_kvp = []
	for child in cim_list.get_children():
		cim_list.remove(child)
		child.queue_free()
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
	actions_box_button.clear()
	var i = 0
	for key in ACT.Type.keys():
		var kvp = [key, ACT.Type[key]]
		actions_box_button.add_item(key, i)
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
	actions_box_button.connect("item_selected", self, "select_default_action")

func select_default_action(action_kvp_id):
	if edited_object:
		edited_object.default_action = act_kvp[action_kvp_id][1]
		edited_object.property_list_changed_notify()

func focus_object(new_obj):
	if edited_object != new_obj:
		edited_object = new_obj
		update_cim_buttons()
		update_default_action()
		update_sam_buttons()
		update_game_stats()
		update_other_stats()

func update_other_stats():
	name_entry.text = edited_object.display_name
	is_player_check.pressed = edited_object.is_player

func update_game_stats():
	if edited_object.game_stats:
		var stats = edited_object.game_stats
		max_hp_box.value = stats.max_hp
		might_box.value = stats.might
		agility_box.value = stats.agility
		stamina_box.value = stats.stamina
		armor_box.value = stats.armor

func update_default_action():
	var kvp_i
	for i in range(act_kvp.size()):
		if act_kvp[i][1] == edited_object.default_action:
			kvp_i = i
	actions_box_button.select(kvp_i)

func update_cim_buttons():
	var cim = edited_object.cim
	print("CIM is: "+ str(cim))
	for kvp in cim_kvp:
		var mask = kvp[1]
		var cbutton: CheckButton = kvp[2]
		cbutton.disabled = false
		cbutton.set_pressed_no_signal(cim & mask > 0)
		#print("cim "+str(kvp[0])+" ("+str(kvp[1])+") is "+ str(cim & mask > 0))

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
		#print("cim "+str(kvp[0])+" ("+str(kvp[1])+") is "+ str(sam & mask > 0))

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


func recalc_cim_and_update(_pressed):
	var new_cim = 0
	for kvp in cim_kvp:
		var cbutton: CheckButton = kvp[2]
		if cbutton.pressed:
			new_cim |= kvp[1]
	edited_object.cim = new_cim
	edited_object.property_list_changed_notify()

func set_icon_list(icons):
	editor_icons = icons
# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func set_game_stat(stat, value):
	if edited_object:
		if not edited_object.game_stats:
			edited_object.game_stats = GameStats.new()
			edited_object.game_stats.resource_local_to_scene = true
		edited_object.game_stats.set(stat, value)
		edited_object.game_stats.property_list_changed_notify()
		edited_object.property_list_changed_notify()

func _on_MaxHPBox_value_changed(value):
	set_game_stat("max_hp", value)
	set_game_stat("current_hp", value)

func _on_MightBox_value_changed(value):
	set_game_stat("might", value)

func _on_AgilityBox_value_changed(value):
	set_game_stat("agility", value)

func _on_StaminaBox_value_changed(value):
	set_game_stat("stamina", value)

func _on_ArmorBox_value_changed(value):
	set_game_stat("armor", value)
	
func _on_NameEdit_text_changed(new_text):
	if edited_object:
		edited_object.display_name = new_text
		edited_object.property_list_changed_notify()

func _on_IsPlayerCheck_toggled(button_pressed):
	if edited_object:
		edited_object.is_player = button_pressed
		edited_object.property_list_changed_notify()
