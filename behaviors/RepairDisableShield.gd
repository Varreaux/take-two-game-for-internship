extends BaseRepairBehavior
class_name RepairDisableShield

func _ready():
	super._ready()
	repair_name = "Restore Shield"
	repair_description = "Re-enables the robot's shield protection"

func can_repair() -> bool:
	if not robot:
		print("RepairDisableShield: No robot found")
		return false
	
	# Check if robot has DisableShieldMalfunction active
	var malfunction_manager = robot.get_node("RobotMalfunctionManager")
	if not malfunction_manager:
		print("RepairDisableShield: No RobotMalfunctionManager found on robot")
		return false
	
	if malfunction_manager.current_malfunction:
		print("RepairDisableShield: Current malfunction name: ", malfunction_manager.current_malfunction.name)
		return malfunction_manager.current_malfunction.name == "DisableShield"
	
	print("RepairDisableShield: No active malfunction")
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
			print("Robot shield restored!")
	else:
		print("Cannot restore shield - robot shield is not disabled!")
		# Show visual feedback
		RepairFeedback.show_feedback(robot, "WRONG REPAIR!")
		repair_failed.emit()
	
	super.repair()