extends BaseMalfunction
class_name InvisibleIntangibleMalfunction

var original_modulate: Color
var original_collision_layer: int
var original_collision_mask: int
var original_y_position: float

func _start_malfunction():
	# Store original properties
	original_modulate = robot.modulate
	original_collision_layer = robot.collision_layer
	original_collision_mask = robot.collision_mask
	original_y_position = robot.global_position.y
	
	# Make invisible and intangible
	robot.modulate = Color(1, 1, 1, 0.3)  # Semi-transparent
	robot.collision_layer = 0  # No collision
	robot.collision_mask = 0   # No collision
	
	# Robot shouts the warning
	RobotShout.shout(robot, "Going INVISIBLE!\nCan't touch me!", 3.0)

func _end_malfunction():
	# Restore original properties
	robot.modulate = original_modulate
	robot.collision_layer = original_collision_layer
	robot.collision_mask = original_collision_mask
	
	# Robot shouts relief
	RobotShout.shout(robot, "I'm visible\nagain!", 2.5)

func _physics_process(delta):
	if is_active:
		# Prevent robot from falling by constraining Y position
		if robot.global_position.y > original_y_position:
			robot.global_position.y = original_y_position
			robot.velocity.y = 0  # Stop falling
