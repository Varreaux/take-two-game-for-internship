extends Node
class_name BaseRepairBehavior

signal repair_used
signal repair_failed

var robot: CharacterBody2D
var repair_name: String = "Repair"
var repair_description: String = "Fixes a malfunction"

func _ready():
	# Try to get robot from parent or scene
	if get_parent() and get_parent() is CharacterBody2D:
		robot = get_parent()
	else:
		# Find robot in scene
		robot = get_tree().get_first_node_in_group("robot-friend")
	
	print("BaseRepairBehavior: Robot found: ", robot != null)
	if robot:
		print("BaseRepairBehavior: Robot name: ", robot.name)
		print("BaseRepairBehavior: Robot groups: ", robot.get_groups())

func can_repair() -> bool:
	# Override in subclasses to check if this repair is applicable
	return false

func repair():
	# Override in subclasses to perform the actual repair
	repair_used.emit()
	print("Repair used: ", repair_name)
