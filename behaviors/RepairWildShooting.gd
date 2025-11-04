extends BaseRepairBehavior
class_name RepairWildShooting

func _ready():
	super._ready()
	repair_name = "Stop Wild Shooting"
	repair_description = "Stops the robot from shooting wildly"

func can_repair() -> bool:
	if not robot:
		return false
	
	# Check if robot has WildShootingMalfunction active
	var malfunction_manager = robot.get_node("RobotMalfunctionManager")
	if malfunction_manager and malfunction_manager.current_malfunction:
		return malfunction_manager.current_malfunction.name == "WildShooting"
	
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
			print("Wild shooting stopped!")
	else:
		print("Cannot stop wild shooting - no wild shooting active!")
		# Show visual feedback
		RepairFeedback.show_feedback(robot, "WRONG REPAIR!")
		repair_failed.emit()
	
	super.repair()