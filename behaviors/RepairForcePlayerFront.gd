extends BaseRepairBehavior
class_name RepairForcePlayerFront

func _ready():
	super._ready()
	repair_name = "Restore Movement"
	repair_description = "Allows the player to move freely again"

func can_repair() -> bool:
	if not robot:
		print("RepairForcePlayerFront: No robot found")
		return false
	
	# Check if robot has ForcePlayerFrontMalfunction active
	var malfunction_manager = robot.get_node("RobotMalfunctionManager")
	if not malfunction_manager:
		print("RepairForcePlayerFront: No RobotMalfunctionManager found on robot")
		return false
	
	if malfunction_manager.current_malfunction:
		print("RepairForcePlayerFront: Current malfunction name: ", malfunction_manager.current_malfunction.name)
		return malfunction_manager.current_malfunction.name == "ForcePlayerFront"
	
	print("RepairForcePlayerFront: No active malfunction")
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
			print("Player movement restored!")
	else:
		print("Cannot restore movement - player is not being forced to front!")
		# Show visual feedback
		RepairFeedback.show_feedback(robot, "WRONG REPAIR!")
		repair_failed.emit()
	
	super.repair()