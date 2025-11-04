extends Node
class_name RepairBehaviorManager

var available_repairs: Array[BaseRepairBehavior] = []
var robot: CharacterBody2D

func _ready():
	robot = get_tree().get_first_node_in_group("robot-friend")
	print("RepairBehaviorManager: Robot found: ", robot != null)
	_initialize_repair_behaviors()

func _initialize_repair_behaviors():
	# Create all repair behaviors for all 7 malfunction types
	var repair_types = [
		RepairInvisibleIntangible,    # InvisibleIntangibleMalfunction
		RepairSelfDestruct,          # SelfDestructMalfunction
		RepairWildShooting,          # WildShootingMalfunction
		RepairWrongDirection,        # WrongDirectionMalfunction
		RepairSuddenDash,            # SuddenDashMalfunction
		RepairDisableShield,         # DisableShieldMalfunction
		RepairForcePlayerFront       # ForcePlayerFrontMalfunction
	]
	
	for repair_type in repair_types:
		var repair = repair_type.new()
		# Connect to repair signals
		repair.repair_failed.connect(_on_repair_failed)
		add_child(repair)
		available_repairs.append(repair)

func get_available_repairs() -> Array[BaseRepairBehavior]:
	# Return only repairs that can be used right now
	var applicable_repairs: Array[BaseRepairBehavior] = []
	
	print("Checking repairs...")
	for repair in available_repairs:
		print("Checking repair: ", repair.repair_name, " - can_repair: ", repair.can_repair())
		if repair.can_repair():
			applicable_repairs.append(repair)
	
	print("Found ", applicable_repairs.size(), " applicable repairs")
	return applicable_repairs

func get_all_repairs() -> Array[BaseRepairBehavior]:
	# Return ALL repair behaviors, regardless of whether they can be used
	print("Returning all ", available_repairs.size(), " repair behaviors")
	return available_repairs

func use_repair(repair: BaseRepairBehavior):
	if repair.can_repair():
		repair.repair()
		print("Used repair: ", repair.repair_name)
	else:
		print("Cannot use repair: ", repair.repair_name, " - no applicable malfunction")
		# Still call repair() to show feedback
		repair.repair()

func _on_repair_failed():
	# Signal to close the behavior menu when wrong repair is used
	# Emit a signal that the player can listen to
	repair_failed.emit()

signal repair_failed