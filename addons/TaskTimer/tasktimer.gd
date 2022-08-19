tool
extends EditorPlugin

var container: VBoxContainer
var timer: LinkButton
var is_stopwatch: bool = false
var is_deadline: bool = false
var deadline: int

func _enter_tree() -> void:
	var editorNode = get_tree().root.get_node("EditorNode")
	var bottomPanel = editorNode.get_node("@@596/@@597/@@605/@@607/@@611/@@615/@@616/@@617/@@5082/@@5083")
	var bottomPanelHBox = bottomPanel.get_node("@@5084")
	
	container = VBoxContainer.new()
	container.add_child(Control.new())
	bottomPanelHBox.add_child_below_node(bottomPanelHBox.get_node("@@5085"), container)
	timer = LinkButton.new()
	timer.text = "Set Timer"
	timer.underline = timer.UNDERLINE_MODE_ON_HOVER
	container.add_child(timer)
	timer.connect("pressed", self, "start_deadline")
	pass

var time_start = 0
var time_now = 0

func _process(delta: float) -> void:
	time_now = Time.get_unix_time_from_system()

	if is_stopwatch:
		var time_elapsed = time_now - time_start
		timer.text = (str(convert_unix(time_elapsed)))
	
	if is_deadline:
		var time_remaining = abs(deadline - time_now)
		timer.text = (str(convert_unix(time_remaining)))

func _exit_tree() -> void:
	container.queue_free()
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

func start_deadline() -> void:
	is_deadline = true
	var timedict = {
		"year": 2022,
		"month": 8,
		"day": 19,
		"hour": 2,
		"minute": 30,
		"second": 0,
	}

	var timezone = Time.get_time_zone_from_system()
	if timezone["bias"] < 0:
		deadline = Time.get_unix_time_from_datetime_dict(timedict) + (abs(timezone["bias"]) * 60)
	else:
		deadline = Time.get_unix_time_from_datetime_dict(timedict) - (timezone * 60)