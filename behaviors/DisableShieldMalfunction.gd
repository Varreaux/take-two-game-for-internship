extends BaseMalfunction
class_name DisableShieldMalfunction

var shield_node: Area2D
var original_shield_visible: bool
var original_collision_enabled: bool

func _start_malfunction():
	# Find shield node (assuming it's a child node)
	shield_node = robot.get_node_or_null("shield")
	if shield_node:
		original_shield_visible = shield_node.visible
		original_collision_enabled = shield_node.monitoring
		shield_node.visible = false
		shield_node.monitoring = false  # Disable collision detection
		# Robot shouts the warning
		RobotShout.shout(robot, "Shield\nDISABLED!", 3.0)
	else:
		print("Robot malfunction: Shield disabled! (No shield node found)")

func _end_malfunction():
	# Restore shield
	if shield_node:
		shield_node.visible = original_shield_visible
		shield_node.monitoring = original_collision_enabled  # Restore collision detection
		# Robot shouts relief
		RobotShout.shout(robot, "Shield\nRESTORED!", 2.5)
	else:
		print("Robot malfunction ended: Shield restored (No shield node found)")

func _physics_process(delta):
	if is_active:
		# Robot is vulnerable to bullets when shield is disabled
		# This will be handled by the bullet collision system
		pass
