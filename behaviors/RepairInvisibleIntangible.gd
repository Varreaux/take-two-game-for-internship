extends BaseRepairBehavior
class_name RepairInvisibleIntangible

func _ready():
	super._ready()
	repair_name = "Restore Visibility"
	repair_description = "Makes the robot visible and solid again"

func can_repair() -> bool:
	if not robot:
		print("RepairInvisibleIntangible: No robot found")
		return false
	
	# Check if robot has RobotMalfunctionManager
	var malfunction_manager = robot.get_node("RobotMalfunctionManager")
	if not malfunction_manager:
		print("RepairInvisibleIntangible: No RobotMalfunctionManager found on robot")
		return false
	
	print("RepairInvisibleIntangible: MalfunctionManager found: ", malfunction_manager)
	print("RepairInvisibleIntangible: Current malfunction: ", malfunction_manager.current_malfunction)
	
	# Check if robot has InvisibleIntangibleMalfunction active
	if malfunction_manager.current_malfunction:
		print("RepairInvisibleIntangible: Current malfunction name: ", malfunction_manager.current_malfunction.name)
		return malfunction_manager.current_malfunction.name == "InvisibleIntangible"
	
	print("RepairInvisibleIntangible: No active malfunction")
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
			print("Robot visibility restored!")
	else:
		print("Cannot restore visibility - robot is not invisible!")
		# Show visual feedback
		RepairFeedback.show_feedback(robot, "WRONG REPAIR!")
		repair_failed.emit()
	
	super.repair()
