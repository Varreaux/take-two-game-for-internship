extends BaseMalfunction
class_name WrongDirectionMalfunction

var original_speed = 0.0
var wrong_direction_speed = -100.0  # Negative speed for backward movement

func _start_malfunction():
	# Store original speed and set wrong direction
	original_speed = robot.velocity.x
	robot.velocity.x = wrong_direction_speed
	# Robot shouts the warning
	RobotShout.shout(robot, "Going the\nWRONG WAY!", 3.0)

func _end_malfunction():
	# Restore normal forward movement
	robot.velocity.x = 0.0  # Will be set to normal speed by robot's normal behavior
	# Robot shouts relief
	RobotShout.shout(robot, "Going the\nright way!", 2.5)

func _physics_process(delta):
	if is_active:
		# Keep pushing backward even if hitting something
		robot.velocity.x = wrong_direction_speed