extends BaseMalfunction
class_name WildShootingMalfunction

var bullet_scene: PackedScene
var shoot_timer = 0.0
var shoot_interval = 0.1  # Very fast shooting

func _start_malfunction():
	# Load bullet scene
	bullet_scene = preload("res://scenes/bullet.tscn")
	# Robot shouts the warning
	RobotShout.shout(robot, "WILD SHOOTING!\nDanger zone!", 3.0)

func _process(delta):
	if is_active:
		shoot_timer += delta
		if shoot_timer >= shoot_interval:
			shoot_timer = 0.0
			_shoot_wildly()

func _shoot_wildly():
	# Use the bullet scene instead of creating manually
	var bullet = bullet_scene.instantiate()
	
	bullet.global_position = robot.global_position + Vector2(105, 0)
	# Shoot in random directions
	var random_angle = randf_range(-PI/4, PI/4)  # 45 degrees up or down
	var bullet_direction = Vector2(1, sin(random_angle)).normalized()
	
	# Set bullet properties
	bullet.direction = bullet_direction
	bullet.speed = 600
	
	# Add bullet to scene
	get_tree().current_scene.add_child(bullet)
	print("Robot fired bullet in direction: ", bullet_direction)

func _end_malfunction():
	# Robot shouts relief
	RobotShout.shout(robot, "Shooting\nstopped!", 2.5)
