extends Node
class_name BaseMalfunction

signal malfunction_started
signal malfunction_ended

var robot: CharacterBody2D
var is_active = false
var duration = 3.0  # Default duration in seconds
var timer: Timer

func _ready():
	# Try to get robot from parent, but don't error if not available
	if get_parent() and get_parent() is CharacterBody2D:
		robot = get_parent()
	
	timer = Timer.new()
	timer.one_shot = true
	timer.timeout.connect(_on_malfunction_timeout)
	add_child(timer)

func activate():
	if is_active:
		return
		
	is_active = true
	malfunction_started.emit()
	_start_malfunction()
	timer.start(duration)

func deactivate():
	if not is_active:
		return
		
	is_active = false
	timer.stop()
	_end_malfunction()
	malfunction_ended.emit()

func _start_malfunction():
	# Override in subclasses
	pass

func _end_malfunction():
	# Override in subclasses
	pass

func _on_malfunction_timeout():
	deactivate()
