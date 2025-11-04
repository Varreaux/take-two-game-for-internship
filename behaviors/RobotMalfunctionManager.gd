extends Node
class_name RobotMalfunctionManager

signal malfunction_started
signal malfunction_ended

@export var malfunction_interval_min = 2.0  # Minimum time between malfunctions
@export var malfunction_interval_max = 2.0  # Maximum time between malfunctions
@export var malfunction_duration_min = 8.0  # Minimum malfunction duration
@export var malfunction_duration_max = 8.0  # Maximum malfunction duration

var robot: CharacterBody2D
var malfunction_timer: Timer
var current_malfunction: BaseMalfunction = null
var available_malfunctions: Array[BaseMalfunction] = []

func _ready():
	robot = get_parent()
	
	# Create malfunction timer
	malfunction_timer = Timer.new()
	malfunction_timer.one_shot = true
	malfunction_timer.timeout.connect(_trigger_random_malfunction)
	add_child(malfunction_timer)
	
	# Initialize available malfunctions
	_initialize_malfunctions()
	
	# Start the malfunction cycle
	_schedule_next_malfunction()

func _initialize_malfunctions():
	# Create instances of all malfunction types with readable names
	var malfunction_data = [
		{"type": WrongDirectionMalfunction, "name": "WrongDirection"},
		{"type": SuddenDashMalfunction, "name": "SuddenDash"},
		{"type": WildShootingMalfunction, "name": "WildShooting"},
		{"type": SelfDestructMalfunction, "name": "SelfDestruct"},
		{"type": InvisibleIntangibleMalfunction, "name": "InvisibleIntangible"},
		{"type": DisableShieldMalfunction, "name": "DisableShield"},
		{"type": ForcePlayerFrontMalfunction, "name": "ForcePlayerFront"}
	]
	
	for data in malfunction_data:
		var malfunction = data.type.new()
		# Set the robot reference manually since we're not adding as child yet
		malfunction.robot = robot
		# Give the malfunction a meaningful name
		malfunction.name = data.name
		available_malfunctions.append(malfunction)
		add_child(malfunction)
		
		# Connect signals - check if the malfunction has the signal first
		if malfunction.has_signal("malfunction_ended"):
			malfunction.malfunction_ended.connect(_on_malfunction_ended)

func _schedule_next_malfunction():
	var random_interval = randf_range(malfunction_interval_min, malfunction_interval_max)
	malfunction_timer.start(random_interval)
	# Next malfunction scheduled

func _trigger_random_malfunction():
	if current_malfunction and current_malfunction.is_active:
		return  # Don't trigger if one is already active
	
	# Check if we have any available malfunctions
	if available_malfunctions.size() == 0:
		print("No malfunctions available, skipping malfunction trigger")
		_schedule_next_malfunction()  # Schedule next attempt
		return
	
	# Select random malfunction
	var random_index = randi() % available_malfunctions.size()
	current_malfunction = available_malfunctions[random_index]
	
	# Set random duration
	var random_duration = randf_range(malfunction_duration_min, malfunction_duration_max)
	current_malfunction.duration = random_duration
	
	# Activate the malfunction
	current_malfunction.activate()
	malfunction_started.emit()  # Emit signal for robot to know

func _on_malfunction_ended():
	current_malfunction = null
	malfunction_ended.emit()  # Emit signal for robot to know
	# Schedule next malfunction
	_schedule_next_malfunction()

# Function to manually stop current malfunction (for player intervention)
func stop_current_malfunction():
	if current_malfunction and current_malfunction.is_active:
		current_malfunction.deactivate()
		print("Malfunction manually stopped by player")
