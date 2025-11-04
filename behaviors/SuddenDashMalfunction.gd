extends BaseMalfunction
class_name SuddenDashMalfunction

var dash_speed = 400.0
var dash_timer = 0.0
var dash_duration = 3.0  # Dash for exactly 3 seconds

func _start_malfunction():
	# Start dashing forward at high speed
	robot.velocity.x = dash_speed
	dash_timer = 0.0
	# Robot shouts the warning
	RobotShout.shout(robot, "SUDDEN DASH!\nHold on!", 2.5)

func _physics_process(delta):
	if is_active:
		# Keep dashing forward
		robot.velocity.x = dash_speed
		
		# Count down the dash timer
		dash_timer += delta
		
		# If dash duration is complete, immediately end the malfunction
		if dash_timer >= dash_duration:
			deactivate()

func _end_malfunction():
	# Stop dashing and return to normal
	robot.velocity.x = 0.0
	# Robot shouts relief
	RobotShout.shout(robot, "Dash\ncomplete!", 2.0)