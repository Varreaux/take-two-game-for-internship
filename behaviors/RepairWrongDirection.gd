extends BaseRepairBehavior
class_name RepairWrongDirection

func _ready():
	super._ready()
	repair_name = "Fix Direction"
	repair_description = "Makes the robot walk in the correct direction again"

func can_repair() -> bool:
	if not robot:
		print("RepairWrongDirection: No robot found")
		return false
	
	# Check if robot has WrongDirectionMalfunction active
	var malfunction_manager = robot.get_node("RobotMalfunctionManager")
	if not malfunction_manager:
		print("RepairWrongDirection: No RobotMalfunctionManager found on robot")
		return false
	
	if malfunction_manager.current_malfunction:
		print("RepairWrongDirection: Current malfunction name: ", malfunction_manager.current_malfunction.name)
		return malfunction_manager.current_malfunction.name == "WrongDirection"
	
	print("RepairWrongDirection: No active malfunction")
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
			print("Robot direction fixed!")
	else:
		print("Cannot fix direction - robot is not walking wrong direction!")
		# Show visual feedback
		RepairFeedback.show_feedback(robot, "WRONG REPAIR!")
		repair_failed.emit()
	
	super.repair()