extends BaseRepairBehavior
class_name RepairSuddenDash

func _ready():
	super._ready()
	repair_name = "Stop Dash"
	repair_description = "Stops the robot from dashing uncontrollably"

func can_repair() -> bool:
	if not robot:
		print("RepairSuddenDash: No robot found")
		return false
	
	# Check if robot has SuddenDashMalfunction active
	var malfunction_manager = robot.get_node("RobotMalfunctionManager")
	if not malfunction_manager:
		print("RepairSuddenDash: No RobotMalfunctionManager found on robot")
		return false
	
	if malfunction_manager.current_malfunction:
		print("RepairSuddenDash: Current malfunction name: ", malfunction_manager.current_malfunction.name)
		return malfunction_manager.current_malfunction.name == "SuddenDash"
	
	print("RepairSuddenDash: No active malfunction")
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
			print("Robot dash stopped!")
	else:
		print("Cannot stop dash - robot is not dashing!")
		# Show visual feedback
		RepairFeedback.show_feedback(robot, "WRONG REPAIR!")
		repair_failed.emit()
	
	super.repair()