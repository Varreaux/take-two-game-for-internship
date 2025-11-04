extends BaseMalfunction
class_name ForcePlayerFrontMalfunction

var player: CharacterBody2D
var original_player_position: Vector2

func _start_malfunction():
	player = get_tree().get_first_node_in_group("player")
	if player:
		# Store original position
		original_player_position = player.global_position
		
		# Teleport player in front of robot
		var teleport_position = robot.global_position + Vector2(100, 0)  # 100 pixels ahead
		player.global_position = teleport_position
		
		# Robot shouts the warning
		RobotShout.shout(robot, "You got this!\nStay in front!", 3.0)
	else:
		print("Robot malfunction: Player not found!")

func _end_malfunction():
	if player:
		# Optionally teleport player back to original position
		# player.global_position = original_player_position
		# Robot shouts relief
		RobotShout.shout(robot, "You're free\nto move!", 2.5)
	else:
		print("Robot malfunction ended: Player control restored")
