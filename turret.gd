extends CharacterBody2D

@export var bullet_scene: PackedScene
@export var destroy_distance = 100.0  # Distance at which turret stops shooting and gets destroyed

var bullet_interval = 0.05  # fast by default
var turret_slowed = false
var robot: CharacterBody2D


func _ready():
	add_to_group("turrets")
	$Timer.stop()  # Stop it first, just to be safe
	$Timer.wait_time = bullet_interval  # Set the faster interval
	$Timer.start()  # Now start it
	
	# Find the robot in the scene
	robot = get_tree().get_first_node_in_group("robot-friend")
	if not robot:
		# Try finding by name "Enemy"
		robot = get_tree().get_first_node_in_group("Enemy")
	if not robot:
		# Try alternative method to find robot
		robot = get_tree().get_first_node_in_group("enemies")
	if not robot:
		# Try finding by name
		robot = get_tree().get_first_node_in_group("robot")
	
	# Debug: Check if robot was found
	if robot:
		print("Turret found robot: ", robot.name, " at position: ", robot.global_position)
	else:
		print("Turret could not find robot!")

func _process(delta):
	# Check distance to robot and handle destruction
	if robot:
		var distance_to_robot = global_position.distance_to(robot.global_position)
		
		# Debug: Print distance every 60 frames (about once per second)
		if Engine.get_process_frames() % 60 == 0:
			print("Turret distance to robot: ", distance_to_robot, " (destroy at: ", destroy_distance, ")")
		
		# If robot is within destroy distance, stop shooting and destroy turret
		if distance_to_robot <= destroy_distance:
			# Stop the timer to prevent more shooting
			$Timer.stop()
			
			# Add a small delay before destruction for visual effect
			await get_tree().create_timer(0.1).timeout
			
			# Destroy the turret
			print("Turret destroyed! Robot got too close (distance: ", distance_to_robot, ")")
			queue_free()
			return

func shoot_bullet():
	var bullet = bullet_scene.instantiate()
	bullet.global_position = global_position + Vector2(-20, 0)  # 10 pixels higher
	bullet.direction = Vector2.LEFT
	bullet.speed = 800  # Only turret sets this
	get_tree().current_scene.add_child(bullet)
	$AnimatedSprite2D.visible = true
	await get_tree().create_timer(0.1).timeout
	if $Timer.wait_time != bullet_interval:
		$AnimatedSprite2D.visible = false
	

func slow_down():
	if not turret_slowed:
		#turret_slowed = true
		$Timer.stop()		
		$Timer.wait_time += 0.1  # much slower
		$Timer.start()


func _on_timer_timeout() -> void:
	#print($Timer.wait_time)
	shoot_bullet()	
