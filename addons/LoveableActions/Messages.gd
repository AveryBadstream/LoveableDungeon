tool
extends GridContainer


onready var pending_message = $Messages/PendingMsgEdit
onready var impossible_message = $Messages/ImpossibleMsgEdit
onready var failed_message = $Messages/FailedMsgEdit
onready var success_message = $Messages/SuccessMsgEdit

onready var impossible_log = $Logs/ImpossibleLogEntry
onready var failed_log = $Logs/FailedLogEntry
onready var success_log = $Logs/SuccessLogEntry
onready var pertarget_log = $Logs/PerTargetLogEntry

var edited_action

func _ready():
	pass # Replace with function body.
	
func change_edited_action(next_edited_action):
	edited_action = next_edited_action
	pending_message.text = edited_action.pending_message
	impossible_message.text = edited_action.impossible_message
	failed_message.text = edited_action.failed_message
	success_message.text = edited_action.success_message
	impossible_log.text = edited_action.impossible_log
	failed_log.text = edited_action.failed_log
	success_log.text = edited_action.success_log
	pertarget_log.text = edited_action.pertarget_log

func set_tab_data():
	edited_action.pending_message = pending_message.text
	edited_action.impossible_message = impossible_message.text
	edited_action.failed_message = failed_message.text
	edited_action.success_message = success_message.text
	edited_action.impossible_log = impossible_log.text
	edited_action.failed_log = failed_log.text
	edited_action.success_log = success_log.text
	edited_action.pertarget_log = pertarget_log.text
