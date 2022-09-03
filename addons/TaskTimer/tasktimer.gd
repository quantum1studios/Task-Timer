tool
extends EditorPlugin

var dialog_scene = preload("res://addons/TaskTimer/timerdialog.tscn")
var dialog: WindowDialog
var months: OptionButton

var container: VBoxContainer
var timer: LinkButton
var is_stopwatch: bool = false
var is_deadline: bool = false
var deadline: int

func _enter_tree() -> void:
	# find the bottom panel hbox, need a better method
	var editorNode = get_tree().root.get_node("EditorNode")
	var bottomPanel = editorNode.get_node("@@596/@@597/@@605/@@607/@@611/@@615/@@616/@@617/@@5082/@@5083")
	var bottomPanelHBox = bottomPanel.get_node("@@5084")
	yield(get_tree().create_timer(1.0), "timeout")

	# initialize the dialog 
	dialog = dialog_scene.instance()
	editorNode.add_child(dialog)
	var options: OptionButton = dialog.get_node("VBoxContainer/date/d_month")
	_add_months(options)
	var startStopwatch: Button = dialog.get_node("VBoxContainer/b_stopwatch")
	startStopwatch.connect("pressed", self, "start_stopwatch")
	var startDeadline: Button = dialog.get_node("VBoxContainer/b_deadline")
	startDeadline.connect("pressed", self, "start_deadline")
	
	# add the timer to the bottom panel
	container = VBoxContainer.new()
	container.add_child(Control.new())
	bottomPanelHBox.add_child_below_node(bottomPanelHBox.get_node("@@5085"), container)
	timer = LinkButton.new()
	timer.text = "Set Timer"
	timer.underline = timer.UNDERLINE_MODE_ON_HOVER
	container.add_child(timer)
	timer.connect("pressed", self, "_edit_timer")
	pass

var time_start = 0
var time_now = 0

func _edit_timer() -> void:
	dialog.show()
	dialog.popup_centered()

func _add_months(options: OptionButton) -> void:
	options.add_item("January", 1)
	options.add_item("February", 2)
	options.add_item("March", 3)
	options.add_item("April", 4)
	options.add_item("May", 5)
	options.add_item("June", 6)
	options.add_item("July", 7)
	options.add_item("August", 8)
	options.add_item("September", 9)
	options.add_item("October", 10)
	options.add_item("November", 11)
	options.add_item("December", 12)

func _process(delta: float) -> void:
	time_now = Time.get_unix_time_from_system()

	if is_stopwatch:
		var time_elapsed = time_now - time_start
		timer.text = (str(convert_unix(time_elapsed)))
	
	if is_deadline:
		var time_remaining = abs(deadline - time_now)
		timer.text = (str(convert_unix(time_remaining)))

func _exit_tree() -> void:
	dialog.queue_free()
	container.queue_free()
	dialog.free()
	container.free()
	pass

func convert_unix(time: int) -> int:
	var seconds = time % 60
	var minutes = time % 3600 / 60
	var hours = floor(time / 3600)
	var str_elapsed = "%02d:%02d:%02d" % [hours, minutes, seconds]
	return str_elapsed

func start_stopwatch() -> void:
	time_start = Time.get_unix_time_from_system()
	is_stopwatch = true
	is_deadline = false

func start_deadline() -> void:
	is_deadline = true
	is_stopwatch = false
	
	var month: OptionButton = dialog.get_node("VBoxContainer/date/d_month")
	var year: TextEdit = dialog.get_node("VBoxContainer/date/t_year")
	var day: TextEdit = dialog.get_node("VBoxContainer/date/t_day")
	var hour: TextEdit = dialog.get_node("VBoxContainer/time/t_hour")
	var minute: TextEdit = dialog.get_node("VBoxContainer/time/t_minute")
	
	var timedict = {
		"year": int(year.text),
		"month": month.selected + 1,
		"day": int(day.text),
		"hour": int(hour.text),
		"minute": int(minute.text),
		"second": 0,
	}

	var timezone = Time.get_time_zone_from_system()
	if timezone["bias"] < 0:
		deadline = Time.get_unix_time_from_datetime_dict(timedict) + (abs(timezone["bias"]) * 60)
	else:
		deadline = Time.get_unix_time_from_datetime_dict(timedict) - (timezone * 60)