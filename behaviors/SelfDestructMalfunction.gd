extends BaseMalfunction
class_name SelfDestructMalfunction

var countdown_timer: Timer
var countdown_duration = 5.0
var explosion_radius = 100.0
var explosion_damage = 50
var countdown_tween: Tween

func _ready():
	super._ready()
	countdown_timer = Timer.new()
	countdown_timer.one_shot = true
	countdown_timer.timeout.connect(_explode)
	add_child(countdown_timer)

func _start_malfunction():
	# Robot shouts the warning
	RobotShout.shout(robot, "SELF-DESTRUCT INITIATED!\n" + str(countdown_duration) + " seconds!", 4.0)
	countdown_timer.start(countdown_duration)
	# Start visual countdown effect
	_start_countdown_effect()

func _start_countdown_effect():
	# Flash red or change color to indicate danger
	countdown_tween = create_tween()
	countdown_tween.set_loops()
	countdown_tween.tween_property(robot.get_node("AnimatedSprite2D"), "modulate", Color.RED, 0.5)
	countdown_tween.tween_property(robot.get_node("AnimatedSprite2D"), "modulate", Color.WHITE, 0.5)

func _explode():
	print("BOOM! Robot exploded!")
	# Damage player if nearby
	var player = get_tree().get_first_node_in_group("player")
	if player and player.global_position.distance_to(robot.global_position) <= explosion_radius:
		print("Player caught in explosion!")
		# Call player damage function if it exists
		if player.has_method("take_damage"):
			player.take_damage(explosion_damage)
	
	# Create explosion effect
	_create_explosion_effect()
	
	# Destroy robot after a short delay to show explosion
	await get_tree().create_timer(0.5).timeout
	robot.queue_free()

func _create_explosion_effect():
	# Create multiple explosion circles for a more dramatic effect
	var explosion_container = Node2D.new()
	explosion_container.global_position = robot.global_position
	get_tree().current_scene.add_child(explosion_container)
	
	# Create multiple colored circles
	var colors = [Color.ORANGE, Color.RED, Color.YELLOW]
	var sizes = [Vector2(20, 20), Vector2(40, 40), Vector2(60, 60)]
	
	for i in range(3):
		var circle = ColorRect.new()
		circle.size = sizes[i]
		circle.color = colors[i]
		circle.position = -sizes[i] / 2  # Center the circle
		explosion_container.add_child(circle)
		
		# Animate each circle
		var circle_tween = create_tween()
		circle_tween.parallel().tween_property(circle, "size", sizes[i] * 4, 0.4)
		circle_tween.parallel().tween_property(circle, "position", -sizes[i] * 2, 0.4)
		circle_tween.parallel().tween_property(circle, "modulate", Color(1, 1, 1, 0), 0.4)
	
	# Add screen shake effect
	_add_screen_shake()
	
	# Clean up explosion container after animation
	await get_tree().create_timer(0.5).timeout
	explosion_container.queue_free()

func _add_screen_shake():
	# Simple screen shake effect
	var camera = get_viewport().get_camera_2d()
	if camera:
		var original_position = camera.global_position
		var shake_tween = create_tween()
		
		# Shake the camera
		for i in range(10):
			var shake_offset = Vector2(randf_range(-5, 5), randf_range(-5, 5))
			shake_tween.tween_property(camera, "global_position", original_position + shake_offset, 0.05)
		
		# Return camera to original position
		shake_tween.tween_property(camera, "global_position", original_position, 0.1)

func _end_malfunction():
	if countdown_timer.time_left > 0:
		countdown_timer.stop()
		# Robot shouts relief
		RobotShout.shout(robot, "Self-destruct\nCANCELLED!", 3.0)
		
		# Stop the countdown flashing effect
		if countdown_tween:
			countdown_tween.kill()
		
		# Return robot to normal color
		var tween = create_tween()
		tween.tween_property(robot.get_node("AnimatedSprite2D"), "modulate", Color.WHITE, 0.2)
