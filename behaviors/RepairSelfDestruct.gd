extends BaseRepairBehavior
class_name RepairSelfDestruct

func _ready():
	super._ready()
	repair_name = "Disarm Self-Destruct"
	repair_description = "Cancels the robot's self-destruct sequence"

func can_repair() -> bool:
	if not robot:
		return false
	
	# Check if robot has SelfDestructMalfunction active
	var malfunction_manager = robot.get_node("RobotMalfunctionManager")
	if malfunction_manager and malfunction_manager.current_malfunction:
		return malfunction_manager.current_malfunction.name == "SelfDestruct"
	
	return false

func repair():
	if not robot:
		print("No robot found!")
		return
	
	# Check if this repair is applicable
	if can_repair():
		# Stop the current malfunction
		var malfunction_manager = robot.get_node("RobotMalfunctionManager")
		if malfunction_manager:
			malfunction_manager.stop_current_malfunction()
			print("Self-destruct sequence disarmed!")
	else:
		print("Cannot disarm self-destruct - no self-destruct active!")
		# Show visual feedback
		RepairFeedback.show_feedback(robot, "WRONG REPAIR!")
		repair_failed.emit()
	
	super.repair()
